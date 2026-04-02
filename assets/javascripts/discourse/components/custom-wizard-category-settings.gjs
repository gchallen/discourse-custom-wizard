import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { popupAjaxError } from "discourse/lib/ajax-error";
import CustomWizardAdmin from "../models/custom-wizard-admin";
import i18n from "discourse/helpers/i18n";
import ComboBox from "select-kit/components/combo-box";
import { hash } from "@ember/helper";

export default class CustomWizardCategorySettings extends Component {
  @tracked wizardList = [];
  @tracked
  wizardListVal = this.args?.category?.custom_fields?.create_topic_wizard;

  constructor() {
    super(...arguments);

    CustomWizardAdmin.all()
      .then((result) => {
        this.wizardList = result;
      })
      .catch(popupAjaxError);
  }

  @action
  changeWizard(wizard) {
    this.wizardListVal = wizard;
    this.args.category.custom_fields.create_topic_wizard = wizard;
  }
<template><h3>{{i18n "admin.wizard.category_settings.custom_wizard.title"}}</h3>
<section class="field new-topic-wizard">
  <label for="new-topic-wizard">
    {{i18n "admin.wizard.category_settings.custom_wizard.create_topic_wizard"}}
  </label>
  <div class="controls">
    <ComboBox @value={{this.wizardListVal}} @content={{this.wizardList}} @onChange={{this.changeWizard}} @options={{hash none="admin.wizard.select"}} />
  </div>
</section></template>}
