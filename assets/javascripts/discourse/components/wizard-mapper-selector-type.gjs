import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { classNameBindings, tagName } from "@ember-decorators/component";

@classNameBindings("active")
@tagName("a")
export default class extends Component {

  @discourseComputed("item.type", "activeType")
  active(type, activeType) {
    return type === activeType;
  }

  click() {
    this.toggle(this.item.type);
  }
<template>{{this.item.label}}</template>}
