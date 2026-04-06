import Component from "@ember/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { alias, not, or } from "@ember/object/computed";
import { schedule } from "@ember/runloop";
import { htmlSafe } from "@ember/template";
import $ from "jquery";
import { cook } from "discourse/lib/text";
import getUrl from "discourse-common/lib/get-url";
import discourseLater from "discourse-common/lib/later";
import discourseComputed, { observes } from "discourse-common/utils/decorators";
import CustomWizard, { updateCachedWizard } from "discourse/plugins/discourse-custom-wizard/discourse/models/custom-wizard";
import { wizardComposerEdtiorEventPrefix } from "./custom-wizard-composer-editor";
import CustomWizardStepForm from "./custom-wizard-step-form";
import customWizardField from "./custom-wizard-field";
import i18n from "discourse/helpers/i18n";
import loadingSpinner from "discourse/helpers/loading-spinner";
import icon from "discourse/helpers/d-icon";
import CustomWizardField from "./custom-wizard-field";
import { classNameBindings } from "@ember-decorators/component";

function openLinksInNewTab(html) {
  const div = document.createElement("div");
  div.innerHTML = html;
  div.querySelectorAll("a[href]").forEach((a) => {
    a.setAttribute("target", "_blank");
    a.setAttribute("rel", "noopener noreferrer");
  });
  return htmlSafe(div.innerHTML);
}

const uploadStartedEventKeys = ["upload-started"];
const uploadEndedEventKeys = [
  "upload-success",
  "upload-error",
  "upload-cancelled",
  "uploads-cancelled",
  "uploads-aborted",
  "all-uploads-complete",
];

@classNameBindings(":wizard-step", "step.id")
export default class extends Component {
  saving = null;

  init() {
    super.init(...arguments);
    this.set("stylingDropdown", {});
  }

  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    cook(this.step.translatedTitle).then((cookedTitle) => {
      this.set("cookedTitle", openLinksInNewTab(cookedTitle));
    });
    cook(this.step.translatedDescription).then((cookedDescription) => {
      this.set("cookedDescription", openLinksInNewTab(cookedDescription));
    });

    uploadStartedEventKeys.forEach((key) => {
      this.appEvents.on(`${wizardComposerEdtiorEventPrefix}:${key}`, () => {
        this.set("uploading", true);
      });
    });
    uploadEndedEventKeys.forEach((key) => {
      this.appEvents.on(`${wizardComposerEdtiorEventPrefix}:${key}`, () => {
        this.set("uploading", false);
      });
    });
  }

  didInsertElement() {
    super.didInsertElement(...arguments);
    this.autoFocus();
  }

  @discourseComputed("step.index", "wizard.required")
  showQuitButton(index, required) {
    return index === 0 && !required;
  }

  @not("step.final") showNextButton;
  @alias("step.final") showDoneButton;
  @or("saving", "uploading") btnsDisabled;

  @discourseComputed(
    "step.index",
    "step.displayIndex",
    "wizard.totalSteps",
    "wizard.completed"
  )
  showFinishButton(index, displayIndex, total, completed) {
    return index !== 0 && displayIndex !== total && completed;
  }

  @discourseComputed("step.index")
  showBackButton(index) {
    return index > 0;
  }

  @discourseComputed("step.banner")
  bannerImage(src) {
    if (!src) {
      return;
    }
    return getUrl(src);
  }

  @discourseComputed("step.id")
  bannerAndDescriptionClass(id) {
    return `wizard-banner-and-description wizard-banner-and-description-${id}`;
  }

  @discourseComputed("step.fields.[]")
  primaryButtonIndex(fields) {
    return fields.length + 1;
  }

  @discourseComputed("step.fields.[]")
  secondaryButtonIndex(fields) {
    return fields.length + 2;
  }

  @observes("step.id")
  _stepChanged() {
    this.set("saving", false);
    this.autoFocus();
  }

  @observes("step.message")
  _handleMessage() {
    const message = this.get("step.message");
    this.showMessage(message);
  }

  @discourseComputed("step.index", "wizard.totalSteps")
  barStyle(displayIndex, totalSteps) {
    let ratio = parseFloat(displayIndex) / parseFloat(totalSteps - 1);
    if (ratio < 0) {
      ratio = 0;
    }
    if (ratio > 1) {
      ratio = 1;
    }

    return htmlSafe(`width: ${ratio * 200}px`);
  }

  @discourseComputed("step.fields")
  includeSidebar(fields) {
    return !!fields.find((f) => f.show_in_sidebar);
  }

  autoFocus() {
    discourseLater(() => {
      schedule("afterRender", () => {
        if ($(".invalid .wizard-focusable").length) {
          this.animateInvalidFields();
        }
      });
    });
  }

  animateInvalidFields() {
    schedule("afterRender", () => {
      let $invalid = $(".invalid .wizard-focusable");
      if ($invalid.length) {
        $([document.documentElement, document.body]).animate(
          {
            scrollTop: $invalid.offset().top - 200,
          },
          400
        );
      }
    });
  }

  advance() {
    this.set("saving", true);
    this.get("step")
      .save()
      .then((response) => {
        updateCachedWizard(CustomWizard.build(response["wizard"]));

        if (response["final"]) {
          CustomWizard.finished(response);
        } else {
          this.goNext(response);
        }
      })
      .catch(() => this.animateInvalidFields())
      .finally(() => this.set("saving", false));
  }

  @action
  quit() {
    this.get("wizard").skip();
  }

  @action
  done() {
    this.send("nextStep");
  }

  @action
  stylingDropdownChanged(id, value) {
    this.set("stylingDropdown", { id, value });
  }

  @action
  exitEarly() {
    const step = this.step;
    step.validate();

    if (step.get("valid")) {
      this.set("saving", true);

      step
        .save()
        .then(() => this.send("quit"))
        .finally(() => this.set("saving", false));
    } else {
      this.autoFocus();
    }
  }

  @action
  backStep() {
    if (this.saving) {
      return;
    }

    this.goBack();
  }

  @action
  nextStep() {
    if (this.saving) {
      return;
    }

    this.step.validate();

    if (this.step.get("valid")) {
      this.advance();
    } else {
      this.autoFocus();
    }
  }
<template><div class="wizard-step-contents">
  {{#if this.step.title}}
    <h1 class="wizard-step-title">{{this.cookedTitle}}</h1>
  {{/if}}

  {{#if this.bannerImage}}
    <div class="wizard-step-banner">
      <img src={{this.bannerImage}} />
    </div>
  {{/if}}

  {{#if this.step.description}}
    <div class="wizard-step-description">{{this.cookedDescription}}</div>
  {{/if}}

  {{#CustomWizardStepForm step=this.step}}
    {{#each this.step.fields as |field|}}
      <CustomWizardField @field={{field}} @step={{this.step}} @wizard={{this.wizard}} />
    {{/each}}
  {{/CustomWizardStepForm}}
</div>

<div class="wizard-step-footer">

  <div class="wizard-progress">
    <div class="white"></div>
    <div class="black" style={{this.barStyle}}></div>
    <div class="screen"></div>
    <span>{{i18n "wizard.step" current=this.step.displayIndex total=this.wizard.totalSteps}}</span>
  </div>

  <div class="wizard-buttons">
    {{#if this.saving}}
      {{loadingSpinner size="small"}}
    {{else}}
      {{#if this.showQuitButton}}
        <a href {{on "click" this.quit}} class="action-link quit" tabindex={{this.secondaryButtonIndex}}>{{i18n "wizard.quit"}}</a>
      {{/if}}
      {{#if this.showBackButton}}
        <a href {{on "click" this.backStep}} class="action-link back" tabindex={{this.secondaryButtonIndex}}>{{i18n "wizard.back"}}</a>
      {{/if}}
    {{/if}}

    {{#if this.showNextButton}}
      <button type="button" class="wizard-btn next primary" {{on "click" this.nextStep}} disabled={{this.btnsDisabled}} tabindex={{this.primaryButtonIndex}}>
        {{i18n "wizard.next"}}
        {{icon "chevron-right"}}
      </button>
    {{/if}}

    {{#if this.showDoneButton}}
      <button type="button" class="wizard-btn done" {{on "click" this.done}} disabled={{this.btnsDisabled}} tabindex={{this.primaryButtonIndex}}>
        {{i18n "wizard.done_custom"}}
      </button>
    {{/if}}
  </div>

</div></template>}
