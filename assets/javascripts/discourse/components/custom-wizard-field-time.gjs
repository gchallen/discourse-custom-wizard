import Component from "@ember/component";
import { action } from "@ember/object";
import { observes } from "discourse-common/utils/decorators";
import customWizardTimeInput from "./custom-wizard-time-input";

export default class extends Component {
  classNameBindings = ["fieldClass"];

  @observes("time")
  setValue() {
    this.set("field.value", this.time.format(this.field.format));
  }

  @action
  onChange(value) {
    this.set(
      "time",
      moment({
        hours: value.hours,
        minutes: value.minutes,
      })
    );
  }
<template>{{customWizardTimeInput date=this.time onChange=this.onChange tabindex=this.field.tabindex}}</template>}
