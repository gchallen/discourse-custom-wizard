import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default class extends Component {
  tagName = "a";
  classNameBindings = ["active"];

  @discourseComputed("item.type", "activeType")
  active(type, activeType) {
    return type === activeType;
  }

  click() {
    this.toggle(this.item.type);
  }
<template>{{this.item.label}}</template>}
