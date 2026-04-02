import Component from "@ember/component";
import { action } from "@ember/object";
import { equal, notEmpty } from "@ember/object/computed";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";
import icon from "discourse/helpers/d-icon";
import i18n from "discourse/helpers/i18n";
import formatDate from "discourse/helpers/format-date";
import discourseTag from "discourse/helpers/discourse-tag";
import { LinkTo } from "@ember/routing";
import avatar from "discourse/helpers/avatar";
import rawDate from "discourse/helpers/raw-date";

export default class extends Component {
  classNameBindings = ["value.type"];
  isText = equal("value.type", "text");
  isComposer = equal("value.type", "composer");
  isDate = equal("value.type", "date");
  isTime = equal("value.type", "time");
  isDateTime = equal("value.type", "date_time");
  isNumber = equal("value.type", "number");
  isCheckbox = equal("value.type", "checkbox");
  isUrl = equal("value.type", "url");
  isUpload = equal("value.type", "upload");
  isDropdown = equal("value.type", "dropdown");
  isTag = equal("value.type", "tag");
  isCategory = equal("value.type", "category");
  isTopic = equal("value.type", "topic");
  isGroup = equal("value.type", "group");
  isUserSelector = equal("value.type", "user_selector");
  isSubmittedAt = equal("field", "submitted_at");
  isComposerPreview = equal("value.type", "composer_preview");
  textState = "text-collapsed";
  toggleText = I18n.t("admin.wizard.expand_text");

  @discourseComputed("value", "isUser", "isSubmittedAt")
  hasValue(value, isUser, isSubmittedAt) {
    if (isUser || isSubmittedAt) {
      return value;
    }
    return value && value.value;
  }

  @discourseComputed("field", "value.type")
  isUser(field, type) {
    return field === "username" || field === "user" || type === "user";
  }

  @discourseComputed("value.type")
  isLongtext(type) {
    return type === "textarea" || type === "long_text";
  }

  @discourseComputed("value")
  checkboxValue(value) {
    const isCheckbox = this.get("isCheckbox");
    if (isCheckbox) {
      return (
        value.value === true ||
        (Array.isArray(value.value) && value.value.includes("true"))
      );
    }
  }

  @action
  expandText() {
    const state = this.get("textState");

    if (state === "text-collapsed") {
      this.set("textState", "text-expanded");
      this.set("toggleText", I18n.t("admin.wizard.collapse_text"));
    } else if (state === "text-expanded") {
      this.set("textState", "text-collapsed");
      this.set("toggleText", I18n.t("admin.wizard.expand_text"));
    }
  }

  @discourseComputed("value")
  file(value) {
    const isUpload = this.get("isUpload");
    if (isUpload) {
      return value.value;
    }
  }

  @discourseComputed("value")
  submittedUsers(value) {
    const isUserSelector = this.get("isUserSelector");
    const users = [];

    if (isUserSelector) {
      const userData = value.value;
      const usernames = [];

      if (userData.indexOf(",")) {
        usernames.push(...userData.split(","));

        usernames.forEach((u) => {
          const user = {
            username: u,
            url: `/u/${u}`,
          };
          users.push(user);
        });
      }
    }
    return users;
  }

  @discourseComputed("isUser", "field", "value")
  username(isUser, field, value) {
    if (isUser) {
      return value.username;
    }
    if (field === "username") {
      return value.value;
    }
    return null;
  }

  showUsername = notEmpty("username");

  @discourseComputed("username")
  userProfileUrl(username) {
    if (username) {
      return `/u/${username}`;
    }
    return "/";
  }

  @discourseComputed("value")
  categoryUrl(value) {
    const isCategory = this.get("isCategory");
    if (isCategory) {
      return `/c/${value.value}`;
    }
  }

  @discourseComputed("value")
  groupUrl(value) {
    const isGroup = this.get("isGroup");
    if (isGroup) {
      return `/g/${value.value}`;
    }
  }
<template>{{#if this.hasValue}}
  {{#if this.isText}}
    {{this.value.value}}
  {{/if}}

  {{#if this.isLongtext}}
    <div class="wizard-table-long-text">
      <p class="wizard-table-long-text-content {{this.textState}}">
        {{this.value.value}}
      </p>
      <a href {{action "expandText"}}>
        {{this.toggleText}}
      </a>
    </div>
  {{/if}}

  {{#if this.isComposer}}
    <div class="wizard-table-long-text">
      <p class="wizard-table-composer-text wizard-table-long-text-content
          {{this.textState}}">
        {{this.value.value}}
      </p>
      <a href {{action "expandText"}}>
        {{this.toggleText}}
      </a>
    </div>
  {{/if}}

  {{#if this.isComposerPreview}}
    {{icon "message"}}
    <span class="wizard-table-composer-text">
      {{i18n "admin.wizard.submissions.composer_preview"}}:
      {{this.value.value}}
    </span>
  {{/if}}

  {{#if this.isTextOnly}}
    {{this.value.value}}
  {{/if}}

  {{#if this.isDate}}
    <span class="wizard-table-icon-item">
      {{icon "calendar"}}{{this.value.value}}
    </span>
  {{/if}}

  {{#if this.isTime}}
    <span class="wizard-table-icon-item">
      {{icon "clock"}}{{this.value.value}}
    </span>
  {{/if}}

  {{#if this.isDateTime}}
    <span class="wizard-table-icon-item" title={{this.value.value}}>
      {{icon "calendar"}}{{formatDate this.value.value format="medium"}}
    </span>
  {{/if}}

  {{#if this.isNumber}}
    {{this.value.value}}
  {{/if}}

  {{#if this.isCheckbox}}
    {{#if this.checkboxValue}}
      <span class="wizard-table-icon-item checkbox-true">
        {{icon "check"}}{{this.value.value}}
      </span>
    {{else}}
      <span class="wizard-table-icon-item checkbox-false">
        {{icon "xmark"}}{{this.value.value}}
      </span>
    {{/if}}
  {{/if}}

  {{#if this.isUrl}}
    <span class="wizard-table-icon-item url">
      {{icon "link"}}
      <a target="_blank" rel="noopener noreferrer" href={{this.value.value}}>
        {{this.value.value}}
      </a>
    </span>
  {{/if}}

  {{#if this.isUpload}}
    <a target="_blank" rel="noopener noreferrer" class="attachment" href={{this.file.url}} download>
      {{this.file.original_filename}}
    </a>
  {{/if}}

  {{#if this.isDropdown}}
    <span class="wizard-table-icon-item">
      {{icon "check-square"}}
      {{this.value.value}}
    </span>
  {{/if}}

  {{#if this.isTag}}
    {{#each this.value.value as |tag|}}
      {{discourseTag tag}}
    {{/each}}
  {{/if}}

  {{#if this.isCategory}}
    <strong>
      {{i18n "admin.wizard.submissions.category_id"}}:
    </strong>
    <a target="_blank" rel="noopener noreferrer" href={{this.categoryUrl}} title={{this.value.value}}>
      {{this.value.value}}
    </a>
  {{/if}}

  {{#if this.isTopic}}
    <strong>
      {{i18n "admin.wizard.submissions.topic_id"}}:
    </strong>
    {{#each this.value.value as |topic|}}
      <a target="_blank" rel="noopener noreferrer" href={{topic.url}} title={{topic.fancy_title}}>
        {{topic.id}}
      </a>
    {{/each}}
  {{/if}}

  {{#if this.isGroup}}
    <strong>
      {{i18n "admin.wizard.submissions.group_id"}}:
    </strong>
    {{this.value.value}}
  {{/if}}

  {{#if this.isUserSelector}}
    {{#each this.submittedUsers as |user|}}
      {{icon "user"}}
      <a target="_blank" rel="noopener noreferrer" href={{user.url}} title={{user.username}}>
        {{user.username}}
      </a>
    {{/each}}
  {{/if}}

  {{#if this.isUser}}
    <LinkTo @route="user" @model={{this.value.username}}>
      {{avatar this.value imageSize="tiny"}}
    </LinkTo>
  {{/if}}

  {{#if this.showUsername}}
    <a target="_blank" rel="noopener noreferrer" href={{this.userProfileUrl}} title={{this.username}}>
      {{this.username}}
    </a>
  {{/if}}

  {{#if this.isSubmittedAt}}
    <span class="date" title={{this.value}}>
      {{rawDate this.value}}
    </span>
  {{/if}}
{{else}}
  &mdash;
{{/if}}</template>}
