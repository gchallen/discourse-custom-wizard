import Component from "@ember/component";
import { action } from "@ember/object";
import comboBox from "select-kit/components/combo-box";
import { hash } from "@ember/helper";

export default class extends Component {
  keyPress(e) {
    e.stopPropagation();
  }

  @action
  onChangeValue(value) {
    this.set("field.value", value);
  }
<template>{{comboBox class=this.fieldClass value=this.field.value content=this.field.content tabindex=this.field.tabindex onChange=(action "onChangeValue") options=(hash none="select_kit.default_header_text")}}</template>}
