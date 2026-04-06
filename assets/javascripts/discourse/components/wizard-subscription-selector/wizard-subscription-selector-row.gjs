import { default as discourseComputed } from "discourse-common/utils/decorators";
import SelectKitRowComponent from "select-kit/components/select-kit/select-kit-row";
import icon from "discourse/helpers/d-icon";
import dasherize from "discourse/helpers/dasherize";
import { trustHTML } from "@ember/template";
import i18n from "discourse/helpers/i18n";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings("isDisabled:disabled")
export default class extends SelectKitRowComponent {

  @discourseComputed("item")
  isDisabled() {
    return this.item.disabled;
  }

  click(event) {
    event.preventDefault();
    event.stopPropagation();
    if (!this.item.disabled) {
      this.selectKit.select(this.rowValue, this.item);
    }
    return false;
  }
<template>{{#if this.icons}}
  <div class="icons">
    <span class="selection-indicator"></span>
    {{#each this.icons as |iconName|}}
      {{icon iconName translatedtitle=(dasherize this.title)}}
    {{/each}}
  </div>
{{/if}}

<div class="texts">
  <span class="name">{{trustHTML this.label}}</span>
  {{#if this.item.subscriptionRequired}}
    <span class="subscription-label">{{i18n this.item.selectorLabel}}</span>
  {{/if}}
</div></template>}
