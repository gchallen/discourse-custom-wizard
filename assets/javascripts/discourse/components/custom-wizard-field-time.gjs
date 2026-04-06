import Component from "@ember/component";
import { action } from "@ember/object";
import { observes } from "@ember-decorators/object";
import customWizardTimeInput from "./custom-wizard-time-input";
import CustomWizardTimeInput from "./custom-wizard-time-input";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings("fieldClass")
export default class extends Component {

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
<template><CustomWizardTimeInput @date={{this.time}} @onChange={{this.onChange}} @tabindex={{this.field.tabindex}} /></template>}
