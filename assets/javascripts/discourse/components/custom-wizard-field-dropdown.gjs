import Component from "@ember/component";
import { action } from "@ember/object";
import comboBox from "select-kit/components/combo-box";
import { hash } from "@ember/helper";
import ComboBox from "select-kit/components/combo-box";

export default class extends Component {
  keyPress(e) {
    e.stopPropagation();
  }

  @action
  onChangeValue(value) {
    this.set("field.value", value);
  }
<template><ComboBox class={{this.fieldClass}} @value={{this.field.value}} @content={{this.field.content}} @tabindex={{this.field.tabindex}} @onChange={{this.onChangeValue}} @options={{(hash none="select_kit.default_header_text")}} /></template>}
