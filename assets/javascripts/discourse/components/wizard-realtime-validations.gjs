import Component, { Input } from "@ember/component";
import { action } from "@ember/object";
import EmberObject from "@ember/object";
import Category from "discourse/models/category";
import { cloneJSON } from "discourse-common/lib/object";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";
import i18n from "discourse/helpers/i18n";
import { concat, get } from "@ember/helper";
import CategorySelector from "select-kit/components/category-selector";
import comboBox from "select-kit/components/combo-box";
import radioButton from "discourse/components/radio-button";

export default class extends Component {
  classNames = ["realtime-validations", "setting", "full", "subscription"];

  @discourseComputed
  timeUnits() {
    return ["days", "weeks", "months", "years"].map((unit) => {
      return {
        id: unit,
        name: I18n.t(`admin.wizard.field.validations.time_units.${unit}`),
      };
    });
  }

  init() {
    super.init(...arguments);
    if (!this.validations) {
      return;
    }

    if (!this.field.validations) {
      const validations = {};

      this.validations.forEach((validation) => {
        validations[validation] = {};
      });

      this.set("field.validations", EmberObject.create(validations));
    }

    const validationBuffer = cloneJSON(this.get("field.validations"));
    let bufferCategories = validationBuffer.similar_topics?.categories || [];
    if (bufferCategories) {
      validationBuffer.similar_topics.categories =
        Category.findByIds(bufferCategories);
    } else {
      validationBuffer.similar_topics.categories = [];
    }
    this.set("validationBuffer", validationBuffer);
  }

  @action
  updateValidationCategories(type, validation, categories) {
    this.set(`validationBuffer.${type}.categories`, categories);
    this.set(
      `field.validations.${type}.categories`,
      categories.map((category) => category.id)
    );
  }
<template><div class="setting-label">
  <label>{{i18n "admin.wizard.field.validations.header"}}</label>
</div>
<div class="setting-value full">
  <ul>
    {{#each-in this.field.validations as |type props|}}
      <li>
        <span class="setting-title">
          <h4>{{i18n (concat "admin.wizard.field.validations." type)}}</h4>
          <Input @type="checkbox" @checked={{props.status}} />
          {{i18n "admin.wizard.field.validations.enabled"}}
        </span>
        <div class="validation-container">
          <div class="validation-section">
            <div class="setting-label">
              <label>{{i18n "admin.wizard.field.validations.categories"}}</label>
            </div>
            <div class="setting-value">
              <CategorySelector @categories={{get this (concat "validationBuffer." type ".categories")}} @onChange={{action "updateValidationCategories" type props}} class="wizard" />
            </div>
          </div>
          <div class="validation-section">
            <div class="setting-label">
              <label>{{i18n "admin.wizard.field.validations.max_topic_age"}}</label>
            </div>
            <div class="setting-value">
              <Input @type="number" @value={{props.time_n_value}} class="time-n-value" />
              {{comboBox value=(readonly props.time_unit) content=this.timeUnits class="time-unit-selector" onChange=(action (mut props.time_unit))}}
            </div>
          </div>
          <div class="validation-section">
            <div class="setting-label">
              <label>{{i18n "admin.wizard.field.validations.position"}}</label>
            </div>
            <div class="setting-value">
              {{radioButton name=(concat type this.field.id) value="above" selection=props.position}}
              <span>{{i18n "admin.wizard.field.validations.above"}}</span>
              {{radioButton name=(concat type this.field.id) value="below" selection=props.position}}
              <span>{{i18n "admin.wizard.field.validations.below"}}</span>
            </div>
          </div>
        </div>
      </li>
    {{/each-in}}
  </ul>
</div></template>}
