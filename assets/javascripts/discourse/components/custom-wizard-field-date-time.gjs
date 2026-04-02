import Component from "@ember/component";
import { action } from "@ember/object";
import { observes } from "discourse-common/utils/decorators";
import customWizardDateTimeInput from "./custom-wizard-date-time-input";

export default class extends Component {
  @observes("dateTime")
  setValue() {
    this.set("field.value", this.dateTime.format(this.field.format));
  }

  @action
  onChange(value) {
    this.set("dateTime", moment(value));
  }
<template>{{customWizardDateTimeInput date=this.dateTime onChange=(action "onChange") tabindex=this.field.tabindex}}</template>}
