import DateInput from "discourse/components/date-input";
import discourseComputed from "discourse-common/utils/decorators";
import { Input } from "@ember/component";
import { on } from "@ember/modifier";

export default class extends DateInput {
  useNativePicker = false;
  classNameBindings = ["fieldClass"];

  @discourseComputed()
  placeholder() {
    return this.format;
  }

  _opts() {
    return {
      format: this.format || "LL",
    };
  }
<template><Input @type={{this.inputType}} @value={{readonly this.value}} class="date-picker" placeholder={{this.placeholder}} tabindex={{this.tabindex}} {{on "input" (action "onChangeDate")}} autocomplete="off" />

<div class="picker-container"></div></template>}
