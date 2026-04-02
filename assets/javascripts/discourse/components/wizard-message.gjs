import Component from "@ember/component";
import { not, notEmpty } from "@ember/object/computed";
import { default as discourseComputed } from "discourse-common/utils/decorators";
import I18n from "I18n";
import icon from "discourse/helpers/d-icon";
import htmlSafe from "discourse/helpers/html-safe";

const icons = {
  error: "circle-xmark",
  success: "circle-check",
  warn: "exclamation-circle",
  info: "circle-info",
};

export default class extends Component {
  classNameBindings = [":wizard-message", "type", "loading"];
  showDocumentation = not("loading");
  showIcon = not("loading");
  hasItems = notEmpty("items");

  @discourseComputed("type")
  icon(type) {
    return icons[type] || "circle-info";
  }

  @discourseComputed("key", "component", "opts")
  message(key, component, opts) {
    return I18n.t(`admin.wizard.message.${component}.${key}`, opts || {});
  }

  @discourseComputed("component")
  documentation(component) {
    return I18n.t(`admin.wizard.message.${component}.documentation`);
  }
<template><div class="message-block primary">
  {{#if this.showIcon}}
    {{icon this.icon}}
  {{/if}}
  <span class="message-content">{{htmlSafe this.message}}</span>
  {{#if this.hasItems}}
    <ul>
      {{#each this.items as |item|}}
        <li>
          <span>{{icon item.icon}}</span>
          <span>{{htmlSafe item.html}}</span>
        </li>
      {{/each}}
    </ul>
  {{/if}}
</div>

{{#if this.showDocumentation}}
  <div class="message-block">
    {{icon "circle-question"}}

    <a href={{this.url}} target="_blank" rel="noopener noreferrer">
      {{this.documentation}}
    </a>
  </div>
{{/if}}</template>}
