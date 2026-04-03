import Component, { Input, Textarea } from "@ember/component";
import { on } from "@ember/modifier";
import { mut } from "discourse/helpers/mut";
import { action } from "@ember/object";
import { computed } from "@ember/object";
import { equal, or } from "@ember/object/computed";
import { default as discourseComputed } from "discourse-common/utils/decorators";
import { selectKitContent } from "../lib/wizard";
import wizardSchema from "../lib/wizard-schema";
import UndoChanges from "../mixins/undo-changes";
import dButton from "discourse/components/d-button";
import i18n from "discourse/helpers/i18n";
import uppyImageUploader from "discourse/components/uppy-image-uploader";
import { concat, hash, fn } from "@ember/helper";
import wizardSubscriptionSelector from "./wizard-subscription-selector";
import wizardMessage from "./wizard-message";
import htmlSafe from "discourse/helpers/html-safe";
import wizardMapper from "./wizard-mapper";
import tagGroupChooser from "select-kit/components/tag-group-chooser";
import CategoryChooser from "select-kit/components/category-chooser";
import comboBox from "select-kit/components/combo-box";
import wizardRealtimeValidations from "./wizard-realtime-validations";
import DButton from "discourse/components/d-button";
import UppyImageUploader from "discourse/components/uppy-image-uploader";
import WizardSubscriptionSelector from "./wizard-subscription-selector";
import WizardMessage from "./wizard-message";
import WizardMapper from "./wizard-mapper";
import ComboBox from "select-kit/components/combo-box";
import WizardRealtimeValidations from "./wizard-realtime-validations";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings(":wizard-custom-field", "visible")
export default class extends Component.extend(UndoChanges) {
  componentType = "field";
  @computed("currentFieldId")
  get visible() {
    return this.field.id === this.currentFieldId;
  }
  @equal("field.type", "dropdown") isDropdown;
  @equal("field.type", "upload") isUpload;
  @equal("field.type", "category") isCategory;
  @equal("field.type", "topic") isTopic;
  @equal("field.type", "group") isGroup;
  @equal("field.type", "tag") isTag;
  @equal("field.type", "text") isText;
  @equal("field.type", "textarea") isTextarea;
  @equal("field.type", "url") isUrl;
  @equal("field.type", "email") isEmail;
  @equal("field.type", "composer") isComposer;
  @or(
    "isText",
    "isCategory",
    "isTag",
    "isGroup",
    "isDropdown",
    "isTopic"
  ) showPrefill;
  @or("isCategory", "isTag", "isGroup", "isDropdown", "isTopic") showContent;
  @or("isCategory", "isTag", "isTopic") showLimit;
  @or("isText", "isTextarea", "isComposer", "isEmail") isTextType;
  @equal("field.type", "composer_preview") isComposerPreview;
  categoryPropertyTypes = selectKitContent(["id", "slug"]);
  messageUrl =
    "https://pavilion.tech/products/discourse-custom-wizard-plugin/documentation/field-settings";

  @discourseComputed("field.type")
  validations(type) {
    const applicableToField = [];

    for (let validation in wizardSchema.field.validations) {
      if (wizardSchema.field.validations[validation]["types"].includes(type)) {
        applicableToField.push(validation);
      }
    }

    return applicableToField;
  }

  @discourseComputed("field.type")
  isDateTime(type) {
    return ["date_time", "date", "time"].indexOf(type) > -1;
  }

  @discourseComputed("field.type")
  messageKey(type) {
    let key = "type";
    if (type) {
      key = "edit";
    }
    return key;
  }

  setupTypeOutput(fieldType, options) {
    const selectionType = {
      category: "category",
      tag: "tag",
      group: "group",
    }[fieldType];

    if (selectionType) {
      options[`${selectionType}Selection`] = "output";
      options.outputDefaultSelection = selectionType;
    }

    return options;
  }

  @discourseComputed("field.type")
  contentOptions(fieldType) {
    let options = {
      wizardFieldSelection: true,
      textSelection: "key,value",
      userFieldSelection: "key,value",
      context: "field",
    };

    options = this.setupTypeOutput(fieldType, options);

    if (this.isDropdown) {
      options.wizardFieldSelection = "key,value";
      options.userFieldOptionsSelection = "output";
      options.textSelection = "key,value";
      options.inputTypes = "association,conditional,assignment";
      options.pairConnector = "association";
      options.keyPlaceholder = "admin.wizard.key";
      options.valuePlaceholder = "admin.wizard.value";
    }

    return options;
  }

  @discourseComputed("field.type")
  prefillOptions(fieldType) {
    let options = {
      wizardFieldSelection: true,
      textSelection: true,
      userFieldSelection: "key,value",
      context: "field",
    };

    return this.setupTypeOutput(fieldType, options);
  }

  @discourseComputed("step.index")
  fieldConditionOptions(stepIndex) {
    const options = {
      inputTypes: "validation",
      context: "field",
      textSelection: "value",
      userFieldSelection: true,
      groupSelection: true,
    };

    if (stepIndex > 0) {
      options.wizardFieldSelection = true;
      options.wizardActionSelection = true;
    }

    return options;
  }

  @discourseComputed("step.index")
  fieldIndexOptions(stepIndex) {
    const options = {
      context: "field",
      userFieldSelection: true,
      groupSelection: true,
    };

    if (stepIndex > 0) {
      options.wizardFieldSelection = true;
      options.wizardActionSelection = true;
    }

    return options;
  }

  @action
  imageUploadDone(upload) {
    this.setProperties({
      "field.image": upload.url,
      "field.image_upload_id": upload.id,
    });
  }

  @action
  imageUploadDeleted() {
    this.setProperties({
      "field.image": null,
      "field.image_upload_id": null,
    });
  }

  @action
  changeCategory(category) {
    this.set("field.category", category?.id);
  }
<template>{{#if this.showUndo}}
  <DButton @action={{this.undoChanges}} @icon={{this.undoIcon}} @label={{this.undoKey}} class="undo-changes" />
{{/if}}

<div class="setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.field.label"}}</label>
  </div>
  <div class="setting-value">
    <Input name="label" @value={{this.field.label}} />
  </div>
</div>

<div class="setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.field.required"}}</label>
  </div>

  <div class="setting-value">
    <span>{{i18n "admin.wizard.field.required_label"}}</span>
    <Input @type="checkbox" @checked={{this.field.required}} />
  </div>
</div>

<div class="setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.field.description"}}</label>
  </div>
  <div class="setting-value">
    <Textarea name="description" @value={{this.field.description}} />
  </div>
</div>

<div class="setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.field.image"}}</label>
  </div>
  <div class="setting-value">
    <UppyImageUploader @imageUrl={{this.field.image}} @onUploadDone={{this.imageUploadDone}} @onUploadDeleted={{this.imageUploadDeleted}} @type="wizard-field-image" class="no-repeat contain-image" @id={{(concat "wizard-field-" this.field.id "-image-upload")}} />
  </div>
</div>

<div class="setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.type"}}</label>
  </div>

  <div class="setting-value">
    <WizardSubscriptionSelector @value={{this.field.type}} @feature="field" @attribute="type" @onChange={{this.changeType}} @wizard={{this.wizard}} @options={{(hash none="admin.wizard.select_type")}} />
  </div>
</div>

<WizardMessage @key={{this.messageKey}} @url={{this.messageUrl}} @component="field" />

{{#if this.isTextType}}
  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.min_length"}}</label>
    </div>

    <div class="setting-value">
      <Input @type="number" name="min_length" @value={{this.field.min_length}} class="small" />
    </div>
  </div>

  <div class="setting full">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.max_length"}}</label>
    </div>

    <div class="setting-value">
      <Input @type="number" name="max_length" @value={{this.field.max_length}} class="small" />
    </div>
  </div>

  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.char_counter"}}</label>
    </div>

    <div class="setting-value">
      <span>{{i18n "admin.wizard.field.char_counter_placeholder"}}</span>
      <Input @type="checkbox" @checked={{this.field.char_counter}} />
    </div>
  </div>

  <div class="setting full">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.field_placeholder"}}</label>
    </div>

    <div class="setting-value">
      <Textarea name="field_placeholder" class="medium" @value={{this.field.placeholder}} />
    </div>
  </div>
{{/if}}

{{#if this.isComposerPreview}}
  <div class="setting full">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.preview_template"}}</label>
    </div>

    <div class="setting-value">
      <Textarea name="preview-template" class="preview-template" @value={{this.field.preview_template}} />
    </div>
  </div>
{{/if}}

{{#if this.isUpload}}
  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.file_types"}}</label>
    </div>

    <div class="setting-value">
      <Input @value={{this.field.file_types}} class="medium" />
    </div>
  </div>
{{/if}}

{{#if this.isEmail}}
  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.allowed_domains"}}</label>
    </div>

    <div class="setting-value">
      <Input @value={{this.field.allowed_domains}} class="large" style="width: 100%;" />
    </div>
  </div>
{{/if}}

{{#if this.showLimit}}
  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.limit"}}</label>
    </div>

    <div class="setting-value">
      <Input @type="number" @value={{this.field.limit}} class="small" />
    </div>
  </div>
{{/if}}

{{#if this.isDateTime}}
  <div class="setting">
    <div class="setting-label">
      <label>{{htmlSafe (i18n "admin.wizard.field.date_time_format.label")}}</label>
    </div>

    <div class="setting-value">
      <Input @value={{this.field.format}} class="medium" />
      <label>{{htmlSafe (i18n "admin.wizard.field.date_time_format.instructions")}}</label>
    </div>
  </div>
{{/if}}

{{#if this.showPrefill}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.prefill"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.field.prefill}} @property="prefill" @onUpdate={{this.mappedFieldUpdated}} @options={{this.prefillOptions}} />
    </div>
  </div>
{{/if}}

{{#if this.showContent}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.content"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.field.content}} @property="content" @onUpdate={{this.mappedFieldUpdated}} @options={{this.contentOptions}} />
    </div>
  </div>
{{/if}}

{{#if this.isTag}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.tag_groups"}}</label>
    </div>

    <div class="setting-value">
      {{tagGroupChooser id=(concat this.field.id "-tag-groups") tagGroups=this.field.tag_groups onChange=(fn (mut this.field.tag_groups))}}
    </div>
  </div>

  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.can_create_tag"}}</label>
    </div>

    <div class="setting-value">
      <Input @type="checkbox" @checked={{this.field.can_create_tag}} />
    </div>
  </div>
{{/if}}

{{#if this.isTopic}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.category.label"}}</label>
    </div>

    <div class="setting-value">
      <CategoryChooser @value={{this.field.category}} @onChangeCategory={{on "click" this.changeCategory}} @options={{hash none="admin.wizard.field.category.none" autoInsertNoneItem=true}} />
    </div>
  </div>
{{/if}}

<div class="setting full field-mapper-setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.condition"}}</label>
  </div>

  <div class="setting-value">
    <WizardMapper @inputs={{this.field.condition}} @options={{this.fieldConditionOptions}} />
  </div>
</div>

<div class="setting full field-mapper-setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.index"}}</label>
  </div>

  <div class="setting-value">
    <WizardMapper @inputs={{this.field.index}} @options={{this.fieldIndexOptions}} />
  </div>
</div>

{{#if this.isCategory}}
  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.field.property"}}</label>
    </div>

    <div class="setting-value">
      <ComboBox @value={{this.field.property}} @content={{this.categoryPropertyTypes}} @onChange={{(fn (mut this.field.property))}} @options={{(hash none="admin.wizard.selector.placeholder.property")}} />
    </div>
  </div>
{{/if}}

{{#if this.validations}}
  <WizardRealtimeValidations @field={{this.field}} @validations={{this.validations}} />
{{/if}}</template>}
