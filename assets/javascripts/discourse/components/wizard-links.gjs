import { A } from "@ember/array";
import Component from "@ember/component";
import EmberObject, { action } from "@ember/object";
import { notEmpty } from "@ember/object/computed";
import discourseComputed from "discourse-common/utils/decorators";
import { generateName } from "../lib/wizard";
import { default as wizardSchema, setWizardDefaults } from "../lib/wizard-schema";
import htmlSafe from "discourse/helpers/html-safe";
import i18n from "discourse/helpers/i18n";
import dButton from "discourse/components/d-button";

export default class extends Component {
  classNameBindings = [":wizard-links", "itemType"];
  items = A();
  @notEmpty("links") anyLinks;

  updateItemOrder(itemId, newIndex) {
    const items = this.items;
    const item = items.findBy("id", itemId);
    items.removeObject(item);
    item.set("index", newIndex);
    items.insertAt(newIndex, item);
  }

  @discourseComputed("itemType")
  header(itemType) {
    return `admin.wizard.${itemType}.header`;
  }

  @discourseComputed(
    "current",
    "items.@each.id",
    "items.@each.type",
    "items.@each.label",
    "items.@each.title"
  )
  links(current, items) {
    if (!items) {
      return;
    }

    return items.map((item, index) => {
      if (item) {
        let link = {
          id: item.id,
        };

        let label = item.label || item.title || item.id;
        if (this.generateLabels && item.type) {
          label = generateName(item.type);
        }

        link.label = `${label} (${item.id})`;

        let classes = "btn";
        if (current && item.id === current.id) {
          classes += " btn-primary";
        }

        link.classes = classes;
        link.index = index;

        if (index === 0) {
          link.first = true;
        }

        if (index === items.length - 1) {
          link.last = true;
        }

        return link;
      }
    });
  }

  getNextIndex() {
    const items = this.items;
    if (!items || items.length === 0) {
      return 0;
    }
    const numbers = items
      .map((i) => Number(i.id.split("_").pop()))
      .sort((a, b) => a - b);
    return numbers[numbers.length - 1];
  }

  @action
  add() {
    const items = this.get("items");
    const itemType = this.itemType;
    let params = setWizardDefaults({}, itemType);

    params.isNew = true;
    params.index = this.getNextIndex();

    let id = `${itemType}_${params.index + 1}`;
    if (itemType === "field") {
      id = `${this.parentId}_${id}`;
    }

    params.id = id;

    let objectArrays = wizardSchema[itemType].objectArrays;
    if (objectArrays) {
      Object.keys(objectArrays).forEach((objectType) => {
        params[objectArrays[objectType].property] = A();
      });
    }

    const newItem = EmberObject.create(params);
    items.pushObject(newItem);

    this.set("current", newItem);
  }

  @action
  back(item) {
    this.updateItemOrder(item.id, item.index - 1);
  }

  @action
  forward(item) {
    this.updateItemOrder(item.id, item.index + 1);
  }

  @action
  change(itemId) {
    this.set("current", this.items.findBy("id", itemId));
  }

  @action
  remove(itemId) {
    const items = this.items;
    let item;
    let index;

    items.forEach((it, ind) => {
      if (it.id === itemId) {
        item = it;
        index = ind;
      }
    });

    let nextIndex;
    if (this.current.id === itemId) {
      nextIndex = index < items.length - 2 ? index + 1 : index - 1;
    }

    items.removeObject(item);

    if (nextIndex) {
      this.set("current", items[nextIndex]);
    }
  }
<template><div class="wizard-header medium">{{htmlSafe (i18n this.header)}}</div>

<div class="link-list">
  {{#if this.anyLinks}}
    {{#each this.links as |link|}}
      <div data-id={{link.id}}>
        {{dButton action=(action "change") actionParam=link.id translatedLabel=link.label class=link.classes}}
        {{#unless link.first}}
          {{dButton action=(action "back") actionParam=link icon="arrow-left" class="back"}}
        {{/unless}}
        {{#unless link.last}}
          {{dButton action=(action "forward") actionParam=link icon="arrow-right" class="forward"}}
        {{/unless}}
        {{dButton action=(action "remove") actionParam=link.id icon="xmark" class="remove"}}
      </div>
    {{/each}}
  {{/if}}
  {{dButton action=(action "add") label="admin.wizard.add" icon="plus"}}
</div></template>}
