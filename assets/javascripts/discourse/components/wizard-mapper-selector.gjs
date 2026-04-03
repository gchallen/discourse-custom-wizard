import { getOwner } from "@ember/application";
import Component, { Input } from "@ember/component";
import { action, computed } from "@ember/object";
import { alias, equal, gt, or } from "@ember/object/computed";
import { bind, later } from "@ember/runloop";
import { service } from "@ember/service";
import $ from "jquery";
import { default as discourseComputed, observes } from "discourse-common/utils/decorators";
import I18n from "I18n";
import { generateName, sentenceCase, snakeCase, userProperties } from "../lib/wizard";
import { defaultSelectionType, selectionTypes } from "../lib/wizard-mapper";
import wizardMapperSelectorType from "./wizard-mapper-selector-type";
import i18n from "discourse/helpers/i18n";
import { on } from "@ember/modifier";
import comboBox from "select-kit/components/combo-box";
import { hash } from "@ember/helper";
import multiSelect from "select-kit/components/multi-select";
import wizardValueList from "./wizard-value-list";
import tagChooser from "select-kit/components/tag-chooser";
import wizardUserChooser from "./wizard-user-chooser";
import WizardMapperSelectorType from "./wizard-mapper-selector-type";
import ComboBox from "select-kit/components/combo-box";
import MultiSelect from "select-kit/components/multi-select";
import WizardValueList from "./wizard-value-list";
import TagChooser from "select-kit/components/tag-chooser";

const customFieldActionMap = {
  topic: ["create_topic", "send_message"],
  post: ["create_topic", "send_message"],
  category: ["create_category"],
  group: ["create_group"],
  user: ["update_profile"],
};

const values = ["present", "true", "false"];

export default class extends Component {
  classNameBindings = [":mapper-selector", "activeType"];
  @service subscription;

  @computed("activeType")
  get showText() {
    return this.showInput("text");
  }
  @computed("activeType")
  get showWizardField() {
    return this.showInput("wizardField");
  }
  @computed("activeType")
  get showWizardAction() {
    return this.showInput("wizardAction");
  }
  @computed("activeType")
  get showUserField() {
    return this.showInput("userField");
  }
  @computed("activeType")
  get showUserFieldOptions() {
    return this.showInput("userFieldOptions");
  }
  @computed("activeType")
  get showCategory() {
    return this.showInput("category");
  }
  @computed("activeType")
  get showTag() {
    return this.showInput("tag");
  }
  @computed("activeType")
  get showGroup() {
    return this.showInput("group");
  }
  @computed("activeType")
  get showUser() {
    return this.showInput("user");
  }
  @computed("activeType")
  get showList() {
    return this.showInput("list");
  }
  @computed("activeType")
  get showCustomField() {
    return this.showInput("customField");
  }
  @computed("activeType")
  get showValue() {
    return this.showInput("value");
  }
  @computed("options.textSelection", "inputType")
  get textEnabled() {
    return this.optionEnabled("textSelection");
  }
  @computed("options.wizardFieldSelection", "inputType")
  get wizardFieldEnabled() {
    return this.optionEnabled("wizardFieldSelection");
  }
  @computed("options.wizardActionSelection", "inputType")
  get wizardActionEnabled() {
    return this.optionEnabled("wizardActionSelection");
  }
  @computed("options.customFieldSelection", "inputType")
  get customFieldEnabled() {
    return this.optionEnabled("customFieldSelection");
  }
  @computed("options.userFieldSelection", "inputType")
  get userFieldEnabled() {
    return this.optionEnabled("userFieldSelection");
  }
  @computed("options.userFieldOptionsSelection", "inputType")
  get userFieldOptionsEnabled() {
    return this.optionEnabled("userFieldOptionsSelection");
  }
  @computed("options.categorySelection", "inputType")
  get categoryEnabled() {
    return this.optionEnabled("categorySelection");
  }
  @computed("options.tagSelection", "inputType")
  get tagEnabled() {
    return this.optionEnabled("tagSelection");
  }
  @computed("options.groupSelection", "inputType")
  get groupEnabled() {
    return this.optionEnabled("groupSelection");
  }
  @computed("options.guestGroup", "inputType")
  get guestGroup() {
    return this.optionEnabled("guestGroup");
  }
  @computed("options.includeMessageableGroups", "inputType")
  get includeMessageableGroups() {
    return this.optionEnabled("includeMessageableGroups");
  }
  @computed("options.userSelection", "inputType")
  get userEnabled() {
    return this.optionEnabled("userSelection");
  }
  @computed("options.listSelection", "inputType")
  get listEnabled() {
    return this.optionEnabled("listSelection");
  }
  @equal("connector", "is") valueEnabled;

  @discourseComputed(
    "site.groups",
    "guestGroup",
    "subscription.subscriptionType"
  )
  groups(groups, guestGroup, subscriptionType) {
    let result = groups;
    if (!guestGroup) {
      return result;
    }

    if (["standard", "business"].includes(subscriptionType)) {
      let guestIndex;
      result.forEach((r, index) => {
        if (r.id === 0) {
          r.name = I18n.t("admin.wizard.selector.label.users");
          guestIndex = index;
        }
      });
      result.splice(guestIndex, 0, {
        id: -1,
        name: I18n.t("admin.wizard.selector.label.guests"),
      });
    }

    return result;
  }
  @alias("site.categories") categories;
  @or(
    "showWizardField",
    "showWizardAction",
    "showUserField",
    "showUserFieldOptions",
    "showCustomField",
    "showValue"
  ) showComboBox;
  @or("showCategory", "showGroup") showMultiSelect;
  @gt("selectorTypes.length", 1) hasTypes;
  showTypes = false;

  didInsertElement() {
    super.didInsertElement(...arguments);
    if (
      !this.activeType ||
      (this.activeType && !this[`${this.activeType}Enabled`])
    ) {
      later(() => this.resetActiveType());
    }

    $(document).on("click", bind(this, this.documentClick));
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    $(document).off("click", bind(this, this.documentClick));
  }

  documentClick(e) {
    if (this._state === "destroying") {
      return;
    }
    let $target = $(e.target);

    if (!$target.parents(".type-selector").length && this.showTypes) {
      this.set("showTypes", false);
    }
  }

  @discourseComputed("connector")
  selectorTypes() {
    return selectionTypes
      .filter((type) => this[`${type}Enabled`])
      .map((type) => ({ type, label: this.typeLabel(type) }));
  }

  @discourseComputed("activeType")
  activeTypeLabel(activeType) {
    return this.typeLabel(activeType);
  }

  typeLabel(type) {
    return type
      ? I18n.t(`admin.wizard.selector.label.${snakeCase(type)}`)
      : null;
  }

  @or("showWizardField", "showWizardAction") comboBoxAllowAny;

  @discourseComputed
  showController() {
    return getOwner(this).lookup("controller:admin-wizards-wizard-show");
  }

  @discourseComputed(
    "activeType",
    "showController.wizardFields.[]",
    "showController.wizard.actions.[]",
    "showController.userFields.[]",
    "showController.currentField.id",
    "showController.currentAction.id",
    "showController.customFields"
  )
  comboBoxContent(
    activeType,
    wizardFields,
    wizardActions,
    userFields,
    currentFieldId,
    currentActionId,
    customFields
  ) {
    let content;
    let context;
    let contextType;

    if (this.options.context) {
      let contextAttrs = this.options.context.split(".");
      context = contextAttrs[0];
      contextType = contextAttrs[1];
    }

    if (activeType === "wizardField") {
      content = wizardFields;

      if (context === "field") {
        content = content.filter((field) => field.id !== currentFieldId);
      }
    }

    if (activeType === "wizardAction") {
      content = wizardActions.map((a) => ({
        id: a.id,
        label: `${generateName(a.type)} (${a.id})`,
        type: a.type,
      }));

      if (context === "action") {
        content = content.filter((a) => a.id !== currentActionId);
      }
    }

    if (activeType === "userField") {
      content = userProperties
        .map((f) => ({
          id: f,
          name: generateName(f),
        }))
        .concat(userFields || []);

      if (
        context === "action" &&
        this.inputType === "association" &&
        this.selectorType === "key"
      ) {
        const excludedFields = ["username", "email", "trust_level"];
        content = content.filter(
          (userField) => excludedFields.indexOf(userField.id) === -1
        );
      }
    }

    if (activeType === "userFieldOptions") {
      content = userFields;
    }

    if (activeType === "customField") {
      content = customFields
        .filter((f) => {
          return (
            f.type !== "json" &&
            customFieldActionMap[f.klass].includes(contextType)
          );
        })
        .map((f) => ({
          id: f.name,
          name: `${sentenceCase(f.klass)} ${f.name} (${f.type})`,
        }));
    }

    if (activeType === "value") {
      content = values.map((value) => ({
        id: value,
        name: value,
      }));
    }

    return content;
  }

  @discourseComputed("activeType")
  multiSelectContent(activeType) {
    return {
      category: this.categories,
      group: this.groups,
      list: "",
    }[activeType];
  }

  @discourseComputed("activeType", "inputType")
  placeholderKey(activeType) {
    if (
      activeType === "text" &&
      this.options[`${this.selectorType}Placeholder`]
    ) {
      return this.options[`${this.selectorType}Placeholder`];
    } else {
      return `admin.wizard.selector.placeholder.${snakeCase(activeType)}`;
    }
  }

  @discourseComputed("activeType")
  multiSelectOptions(activeType) {
    let result = {
      none: this.placeholderKey,
    };

    if (activeType === "list") {
      result.allowAny = true;
    }

    return result;
  }

  @discourseComputed("includeMessageableGroups", "options.userLimit")
  userOptions(includeMessageableGroups, userLimit) {
    const opts = {
      includeMessageableGroups,
    };
    if (userLimit) {
      opts.maximum = userLimit;
    }
    return opts;
  }

  optionEnabled(type) {
    const options = this.options;
    if (!options) {
      return false;
    }

    const option = options[type];
    if (option === true) {
      return true;
    }
    if (typeof option !== "string") {
      return false;
    }

    return option.split(",").filter((o) => {
      return [this.selectorType, this.inputType].indexOf(o) !== -1;
    }).length;
  }

  showInput(type) {
    return this.activeType === type && this[`${type}Enabled`];
  }

  _updateValue(value) {
    this.set("value", value);
    this.onUpdate("selector", this.activeType);
  }

  @observes("inputType")
  resetActiveType() {
    this.set(
      "activeType",
      defaultSelectionType(this.selectorType, this.options, this.connector)
    );
  }

  @action
  toggleType(type) {
    this.set("activeType", type);
    this.set("showTypes", false);
    this.set("value", null);
    this.onUpdate("selector");
  }

  @action
  toggleTypes() {
    this.toggleProperty("showTypes");
  }

  @action
  changeValue(value) {
    this._updateValue(value);
  }

  @action
  changeInputValue(event) {
    this._updateValue(event.target.value);
  }

  @action
  changeUserValue(value) {
    this._updateValue(value);
  }
<template><div class="type-selector">
  {{#if this.hasTypes}}
    <a role="button" {{on "click" this.toggleTypes}} class="active">
      {{this.activeTypeLabel}}
    </a>

    {{#if this.showTypes}}
      <div class="selector-types">
        {{#each this.selectorTypes as |item|}}
          <WizardMapperSelectorType @activeType={{this.activeType}} @item={{item}} @toggle={{this.toggleType}} />
        {{/each}}
      </div>
    {{/if}}
  {{else}}
    <span>{{this.activeTypeLabel}}</span>
  {{/if}}
</div>

<div class="input">
  {{#if this.showText}}
    <Input @type="text" @value={{this.value}} placeholder={{i18n this.placeholderKey}} {{on "change" this.changeInputValue}} />
  {{/if}}

  {{#if this.showComboBox}}
    <ComboBox @value={{this.value}} @content={{this.comboBoxContent}} @onChange={{this.changeValue}} @options={{(hash none=this.placeholderKey allowAny=this.comboBoxAllowAny)}} />
  {{/if}}

  {{#if this.showMultiSelect}}
    <MultiSelect @content={{this.multiSelectContent}} @value={{this.value}} @onChange={{this.changeValue}} @options={{this.multiSelectOptions}} />
  {{/if}}

  {{#if this.showList}}
    <WizardValueList @values={{this.value}} @addKey={{this.placeholderKey}} @onChange={{this.changeValue}} />
  {{/if}}

  {{#if this.showTag}}
    <TagChooser @tags={{this.value}} @onChange={{this.changeValue}} @everyTag={{true}} @options={{(hash none=this.placeholderKey filterable=true)}} />
  {{/if}}

  {{#if this.showUser}}
    {{wizardUserChooser placeholderKey=this.placeholderKey value=this.value autocomplete="discourse" onChange=this.changeUserValue options=this.userOptions}}
  {{/if}}
</div></template>}
