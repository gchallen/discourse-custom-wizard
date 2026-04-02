import Component, { Input } from "@ember/component";
import { action } from "@ember/object";
import { alias, equal, or } from "@ember/object/computed";
import discourseComputed, { observes } from "discourse-common/utils/decorators";
import I18n from "I18n";
import wizardSubscriptionSelector from "./wizard-subscription-selector";
import { hash } from "@ember/helper";
import i18n from "discourse/helpers/i18n";
import multiSelect from "select-kit/components/multi-select";
import loadingSpinner from "discourse/helpers/loading-spinner";
import icon from "discourse/helpers/d-icon";
import dButton from "discourse/components/d-button";

export default class extends Component {
  tagName = "tr";
  topicSerializers = ["topic_view", "topic_list_item"];
  postSerializers = ["post"];
  groupSerializers = ["basic_group"];
  categorySerializers = ["basic_category"];
  showInputs = or("field.new", "field.edit");
  classNames = ["custom-field-input"];
  loading = or("saving", "destroying");
  destroyDisabled = alias("loading");
  closeDisabled = alias("loading");
  isExternal = equal("field.id", "external");

  didInsertElement() {
    super.didInsertElement(...arguments);
    this.set("originalField", JSON.parse(JSON.stringify(this.field)));
  }

  @discourseComputed("field.klass")
  serializerContent(klass) {
    const serializers = this.get(`${klass}Serializers`);

    if (serializers) {
      return serializers.reduce((result, key) => {
        result.push({
          id: key,
          name: I18n.t(`admin.wizard.custom_field.serializers.${key}`),
        });
        return result;
      }, []);
    }
  }

  @observes("field.klass")
  clearSerializersWhenClassChanges() {
    this.set("field.serializers", null);
  }

  compareArrays(array1, array2) {
    return (
      array1.length === array2.length &&
      array1.every((value, index) => {
        return value === array2[index];
      })
    );
  }

  @discourseComputed(
    "saving",
    "isExternal",
    "field.name",
    "field.klass",
    "field.type",
    "field.serializers"
  )
  saveDisabled(saving, isExternal) {
    if (saving || isExternal) {
      return true;
    }

    const originalField = this.originalField;
    if (!originalField) {
      return false;
    }

    return ["name", "klass", "type", "serializers"].every((attr) => {
      let current = this.get(attr);
      let original = originalField[attr];

      if (!current) {
        return false;
      }

      if (attr === "serializers") {
        return this.compareArrays(current, original);
      } else {
        return current === original;
      }
    });
  }

  @action
  edit() {
    this.set("field.edit", true);
  }

  @action
  close() {
    if (this.field.edit) {
      this.set("field.edit", false);
    }
  }

  @action
  destroy() {
    this.set("destroying", true);
    this.removeField(this.field);
  }

  @action
  save() {
    this.set("saving", true);

    const field = this.field;

    let data = {
      id: field.id,
      klass: field.klass,
      type: field.type,
      serializers: field.serializers,
      name: field.name,
    };

    this.saveField(data).then((result) => {
      this.set("saving", false);
      if (result.success) {
        this.set("field.edit", false);
      } else {
        this.set("saveIcon", "xmark");
      }
      setTimeout(() => {
        if (this.isDestroyed) {
          return;
        }
        this.set("saveIcon", null);
      }, 10000);
    });
  }
<template>{{#if this.showInputs}}
  <td>
    {{wizardSubscriptionSelector value=this.field.klass feature="custom_field" attribute="klass" onChange=(action (mut this.field.klass)) options=(hash none="admin.wizard.custom_field.klass.select")}}
  </td>
  <td>
    {{wizardSubscriptionSelector value=this.field.type feature="custom_field" attribute="type" onChange=(action (mut this.field.type)) options=(hash none="admin.wizard.custom_field.type.select")}}
  </td>
  <td class="input">
    <Input @value={{this.field.name}} placeholder={{i18n "admin.wizard.custom_field.name.select"}} />
  </td>
  <td class="multi-select">
    {{multiSelect value=this.field.serializers content=this.serializerContent onChange=(action (mut this.field.serializers)) options=(hash none="admin.wizard.custom_field.serializers.select")}}
  </td>
  <td class="actions">
    {{#if this.loading}}
      {{loadingSpinner size="small"}}
    {{else}}
      {{#if this.saveIcon}}
        {{icon this.saveIcon}}
      {{/if}}
    {{/if}}
    {{dButton action=(action "destroy") icon="trash-can" class="destroy" disabled=this.destroyDisabled}}
    {{dButton icon="floppy-disk" action=(action "save") disabled=this.saveDisabled class="save"}}
    {{dButton action=(action "close") icon="xmark" disabled=this.closeDisabled}}
  </td>
{{else}}
  <td><label>{{this.field.klass}}</label></td>
  <td><label>{{this.field.type}}</label></td>
  <td class="input"><label>{{this.field.name}}</label></td>
  <td class="multi-select">
    {{#if this.isExternal}}
      &mdash;
    {{else}}
      {{#each this.field.serializers as |serializer|}}
        <label>{{serializer}}</label>
      {{/each}}
    {{/if}}
  </td>
  {{#if this.isExternal}}
    <td class="external">
      <label title={{i18n "admin.wizard.custom_field.external.title"}}>
        {{i18n "admin.wizard.custom_field.external.label"}}
      </label>
    </td>
  {{else}}
    <td class="actions">
      {{dButton action=(action "edit") icon="pencil"}}
    </td>
  {{/if}}
{{/if}}</template>}
