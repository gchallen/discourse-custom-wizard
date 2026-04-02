import Component from "@ember/component";
import { action } from "@ember/object";
import customWizardTopicSelector from "./custom-wizard-topic-selector";
import { hash } from "@ember/helper";

export default class extends Component {
  topics = [];

  didInsertElement() {
    super.didInsertElement(...arguments);
    const value = this.field.value;

    if (value) {
      this.set("topics", value);
    }
  }

  @action
  setValue(_, topics) {
    if (topics.length) {
      this.set("field.value", topics);
    }
  }
<template>{{customWizardTopicSelector topics=this.topics category=this.field.category onChange=this.setValue options=(hash maximum=this.field.limit)}}</template>}
