import SelectKitRowComponent from "select-kit/components/select-kit/select-kit-row";
import avatar from "discourse/helpers/avatar";
import formatUsername from "discourse/helpers/format-username";
import and from "truth-helpers/helpers/and";
import UserStatusMessage from "discourse/components/user-status-message";
import decorateUsernameSelector from "discourse/helpers/decorate-username-selector";
import icon from "discourse/helpers/d-icon";
import { classNames } from "@ember-decorators/component";

@classNames("user-row", "wizard-user-chooser-row")
export default class extends SelectKitRowComponent {
<template>{{#if this.item.isUser}}
  {{avatar this.item imageSize="tiny"}}
  <div>
    <span class="identifier">{{formatUsername this.item.id}}</span>
    <span class="name">{{this.item.name}}</span>
  </div>
  {{#if (and this.item.showUserStatus this.item.status)}}
    <UserStatusMessage @status={{this.item.status}} @showDescription={{true}} />
  {{/if}}
  {{decorateUsernameSelector this.item.id}}
{{else if this.item.isGroup}}
  {{icon "users"}}
  <div>
    <span class="identifier">{{this.item.id}}</span>
    <span class="name">{{this.item.full_name}}</span>
  </div>
{{else}}
  {{icon "envelope"}}
  <span class="identifier">{{this.item.id}}</span>
{{/if}}</template>}
