import Component from "@ember/component";
import { action } from "@ember/object";
import { observes } from "discourse-common/utils/decorators";
import customWizardDateInput from "./custom-wizard-date-input";
import CustomWizardDateInput from "./custom-wizard-date-input";

export default class extends Component {
  @observes("date")
  setValue() {
    this.set("field.value", this.date.format(this.field.format));
  }

  @action
  onChange(value) {
    this.set("date", moment(value));
  }
<template><CustomWizardDateInput @date={{this.date}} @onChange={{this.onChange}} @tabindex={{this.field.tabindex}} @format={{this.field.format}} /></template>}
