import DateInput from "discourse/components/date-input";
import discourseComputed from "discourse-common/utils/decorators";
import { Input } from "@ember/component";
import { on } from "@ember/modifier";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings("fieldClass")
export default class extends DateInput {
  useNativePicker = false;

  @discourseComputed()
  placeholder() {
    return this.format;
  }

  _opts() {
    return {
      format: this.format || "LL",
    };
  }
<template><Input @type={{this.inputType}} @value={{readonly this.value}} class="date-picker" placeholder={{this.placeholder}} tabindex={{this.tabindex}} {{on "input" this.onChangeDate}} autocomplete="off" />

<div class="picker-container"></div></template>}
