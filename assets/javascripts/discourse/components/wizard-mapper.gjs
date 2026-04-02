import { A } from "@ember/array";
import Component from "@ember/component";
import { action } from "@ember/object";
import { later } from "@ember/runloop";
import discourseComputed from "discourse-common/utils/decorators";
import { newInput, selectionTypes } from "../lib/wizard-mapper";
import wizardMapperConnector from "./wizard-mapper-connector";
import wizardMapperInput from "./wizard-mapper-input";
import dButton from "discourse/components/d-button";

export default class extends Component {
  classNames = "wizard-mapper";

  didReceiveAttrs() {
    super.didReceiveAttrs();
    if (this.inputs && this.inputs.constructor !== Array) {
      later(() => this.set("inputs", null));
    }
  }

  @discourseComputed("inputs.@each.type")
  canAdd(inputs) {
    return (
      !inputs ||
      inputs.constructor !== Array ||
      inputs.every((i) => {
        return ["assignment", "association"].indexOf(i.type) === -1;
      })
    );
  }

  @discourseComputed("options.@each.inputType")
  inputOptions(options) {
    let result = {
      inputTypes: options.inputTypes || "assignment,conditional",
      inputConnector: options.inputConnector || "or",
      pairConnector: options.pairConnector || null,
      outputConnector: options.outputConnector || null,
      context: options.context || null,
      guestGroup: options.guestGroup || false,
      includeMessageableGroups: options.includeMessageableGroups || false,
      userLimit: options.userLimit || null,
    };

    let inputTypes = ["key", "value", "output"];
    inputTypes.forEach((type) => {
      result[`${type}Placeholder`] = options[`${type}Placeholder`] || null;
      result[`${type}DefaultSelection`] =
        options[`${type}DefaultSelection`] || null;
    });

    selectionTypes.forEach((type) => {
      if (options[`${type}Selection`] !== undefined) {
        result[`${type}Selection`] = options[`${type}Selection`];
      } else {
        result[`${type}Selection`] = type === "text" ? true : false;
      }
    });

    return result;
  }

  onUpdate() {}

  @action
  add() {
    if (!this.get("inputs")) {
      this.set("inputs", A());
    }

    this.get("inputs").pushObject(
      newInput(this.inputOptions, this.inputs.length)
    );

    this.onUpdate(this.property, "input");
  }

  @action
  remove(input) {
    const inputs = this.inputs;
    inputs.removeObject(input);

    if (inputs.length) {
      inputs[0].set("connector", null);
    }

    this.onUpdate(this.property, "input");
  }

  @action
  inputUpdated(component, type) {
    this.onUpdate(this.property, component, type);
  }
<template>{{#each this.inputs as |input|}}
  {{#if input.connector}}
    {{wizardMapperConnector connector=input.connector connectorType="input" onUpdate=(action "inputUpdated")}}
  {{/if}}

  {{wizardMapperInput input=input options=this.inputOptions remove=(action "remove") onUpdate=(action "inputUpdated")}}
{{/each}}

{{#if this.canAdd}}
  <span class="add-mapper-input">
    {{dButton action=(action "add") label="admin.wizard.add" icon="plus"}}
  </span>
{{/if}}</template>}
