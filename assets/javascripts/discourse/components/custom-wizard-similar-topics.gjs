import Component from "@ember/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { bind } from "@ember/runloop";
import $ from "jquery";
import { observes } from "discourse-common/utils/decorators";
import customWizardSimilarTopic from "./custom-wizard-similar-topic";
import i18n from "discourse/helpers/i18n";

export default class extends Component {
  classNames = ["wizard-similar-topics"];
  showTopics = true;

  didInsertElement() {
    super.didInsertElement(...arguments);
    $(document).on("click", bind(this, this.documentClick));
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    $(document).off("click", bind(this, this.documentClick));
  }

  documentClick(e) {
    if (this._state === "destroying") {
      return;
    }
    let $target = $(e.target);

    if (!$target.hasClass("show-topics")) {
      this.set("showTopics", false);
    }
  }

  @observes("topics")
  toggleShowWhenTopicsChange() {
    this.set("showTopics", true);
  }

  @action
  toggleShowTopics() {
    this.set("showTopics", true);
  }
<template>{{#if this.showTopics}}
  <ul>
    {{#each this.topics as |topic|}}
      <li>{{customWizardSimilarTopic topic=topic}}</li>
    {{/each}}
  </ul>
{{else}}
  <a role="button" class="show-topics" {{on "click" this.toggleShowTopics}}>
    {{i18n "realtime_validations.similar_topics.show"}}
  </a>
{{/if}}</template>}
