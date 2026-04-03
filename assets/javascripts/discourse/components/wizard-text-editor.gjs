import Component from "@ember/component";
import { action } from "@ember/object";
import { notEmpty } from "@ember/object/computed";
import { scheduleOnce } from "@ember/runloop";
import $ from "jquery";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";
import { userProperties } from "../lib/wizard";
import dEditor from "discourse/components/d-editor";
import dButton from "discourse/components/d-button";
import i18n from "discourse/helpers/i18n";
import DEditor from "discourse/components/d-editor";
import DButton from "discourse/components/d-button";

const excludedUserProperties = ["profile_background", "card_background"];

export default class extends Component {
  classNames = "wizard-text-editor";
  barEnabled = true;
  previewEnabled = true;
  fieldsEnabled = true;
  hasWizardFields = notEmpty("wizardFieldList");
  hasWizardActions = notEmpty("wizardActionList");

  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    if (!this.barEnabled) {
      scheduleOnce("afterRender", this, this._hideButtonBar);
    }
  }

  _hideButtonBar() {
    $(this.element).find(".d-editor-button-bar").addClass("hidden");
  }

  @discourseComputed("forcePreview")
  previewLabel(forcePreview) {
    return I18n.t("admin.wizard.editor.preview", {
      action: I18n.t(`admin.wizard.editor.${forcePreview ? "hide" : "show"}`),
    });
  }

  @discourseComputed("showPopover")
  popoverLabel(showPopover) {
    return I18n.t("admin.wizard.editor.popover", {
      action: I18n.t(`admin.wizard.editor.${showPopover ? "hide" : "show"}`),
    });
  }

  @discourseComputed()
  userPropertyList() {
    return userProperties
      .filter((f) => !excludedUserProperties.includes(f))
      .map((f) => ` u{${f}}`);
  }

  @discourseComputed("wizardFields")
  wizardFieldList(wizardFields) {
    return (wizardFields || []).map((f) => ` w{${f.id}}`);
  }

  @discourseComputed("wizardActions")
  wizardActionList(wizardActions) {
    return (wizardActions || []).map((a) => ` w{${a.id}}`);
  }

  @action
  togglePreview() {
    this.toggleProperty("forcePreview");
  }

  @action
  togglePopover() {
    this.toggleProperty("showPopover");
  }
<template><DEditor @value={{this.value}} @forcePreview={{this.forcePreview}} @placeholder={{this.placeholder}} />

<div class="wizard-editor-gutter">
  {{#if this.previewEnabled}}
    <DButton @action={{this.togglePreview}} @translatedLabel={{this.previewLabel}} />
  {{/if}}

  {{#if this.fieldsEnabled}}
    <DButton @action={{this.togglePopover}} @translatedLabel={{this.popoverLabel}} />

    {{#if this.showPopover}}
      <div class="wizard-editor-gutter-popover">
        <label>
          {{i18n "admin.wizard.action.post_builder.user_properties"}}
          {{this.userPropertyList}}
        </label>

        {{#if this.hasWizardFields}}
          <label>
            {{i18n "admin.wizard.action.post_builder.wizard_fields"}}
            {{this.wizardFieldList}}
          </label>
        {{/if}}

        {{#if this.hasWizardActions}}
          <label>
            {{i18n "admin.wizard.action.post_builder.wizard_actions"}}
            {{this.wizardActionList}}
          </label>
        {{/if}}
      </div>
    {{/if}}
  {{/if}}
</div></template>}
