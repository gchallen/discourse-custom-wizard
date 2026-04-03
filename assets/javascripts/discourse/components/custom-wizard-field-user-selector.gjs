import Component from "@ember/component";
import { action, computed } from "@ember/object";
import customUserSelector from "./custom-user-selector";
import CustomUserSelector from "./custom-user-selector";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings("fieldClass")
export default class extends Component {

  @computed("includeGroups")
  get _includeGroups() {
    return this.get("includeGroups");
  }

  @computed("includeMentionableGroups")
  get _includeMentionableGroups() {
    return this.get("includeMentionableGroups");
  }

  @computed("includeMessageableGroups")
  get _includeMessageableGroups() {
    return this.get("includeMessageableGroups");
  }

  @computed("allowedUsers")
  get _allowedUsers() {
    return this.get("allowedUsers");
  }

  @computed("single")
  get _single() {
    return this.get("single");
  }

  @computed("topicId")
  get _topicId() {
    return this.get("topicId");
  }

  @computed("disabled")
  get _disabled() {
    return this.get("disabled");
  }

  get _onChangeCallback() {
    return this.get("onChangeCallback");
  }

  @action
  updateFieldValue(usernames) {
    this.set("field.value", usernames);

    // Call the original callback if it exists
    const originalCallback = this.get("onChangeCallback");
    if (originalCallback) {
      originalCallback();
    }
  }
<template><CustomUserSelector @usernames={{this.field.value}} @includeGroups={{this._includeGroups}} @includeMentionableGroups={{this._includeMentionableGroups}} @includeMessageableGroups={{this._includeMessageableGroups}} @allowedUsers={{this._allowedUsers}} @single={{this._single}} @topicId={{this._topicId}} @disabled={{this._disabled}} @onChangeCallback={{this.updateFieldValue}} /></template>}
