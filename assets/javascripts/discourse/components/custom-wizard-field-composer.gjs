import Component from "@ember/component";
import EmberObject, { action } from "@ember/object";
import { default as computed } from "discourse-common/utils/decorators";
import { observes } from "@ember-decorators/object";
import CustomWizardComposerEditor from "./custom-wizard-composer-editor";
import DButton from "discourse/components/d-button";
import wizardCharCounter from "../helpers/wizard-char-counter";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings(":wizard-field-composer", "showPreview:show-preview:hide-preview")
export default class extends Component {
  showPreview = false;

  init() {
    super.init(...arguments);
    this.set(
      "composer",
      EmberObject.create({
        loading: false,
        model: {
          reply: this.get("field.value") || "",
        },
        afterRefresh: () => {},
        allowUpload: true,
      })
    );
  }

  @observes("composer.model.reply")
  setField() {
    this.set("field.value", this.get("composer.model.reply"));
  }

  @computed("showPreview")
  togglePreviewLabel(showPreview) {
    return showPreview
      ? "wizard_composer.hide_preview"
      : "wizard_composer.show_preview";
  }

  @action
  importQuote() {}

  @action
  groupsMentioned() {}

  @action
  afterRefresh() {}

  @action
  cannotSeeMention() {}

  @action
  showUploadSelector() {}

  @action
  togglePreview() {
    this.toggleProperty("showPreview");
  }
<template><CustomWizardComposerEditor @field={{this.field}} @composer={{this.composer}} @wizard={{this.wizard}} @fieldClass={{this.fieldClass}} @groupsMentioned={{this.groupsMentioned}} @cannotSeeMention={{this.cannotSeeMention}} @importQuote={{this.importQuote}} @togglePreview={{this.togglePreview}} @afterRefresh={{this.afterRefresh}} />

<div class="bottom-bar">
  <DButton @action={{this.togglePreview}} class="wizard-btn toggle-preview" @label={{this.togglePreviewLabel}} />

  {{#if this.field.char_counter}}
    {{wizardCharCounter this.field.value this.field.max_length}}
  {{/if}}
</div></template>}
