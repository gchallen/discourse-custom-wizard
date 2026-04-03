import { A } from "@ember/array";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import Component from "@ember/component";
import { action, computed, set } from "@ember/object";
import { alias, equal, not, or } from "@ember/object/computed";
import { observes } from "discourse-common/utils/decorators";
import { connectorContent, defaultConnector, defaultSelectionType, inputTypesContent, newPair } from "../lib/wizard-mapper";
import wizardMapperConnector from "./wizard-mapper-connector";
import wizardMapperPair from "./wizard-mapper-pair";
import icon from "discourse/helpers/d-icon";
import wizardMapperSelector from "./wizard-mapper-selector";
import WizardMapperConnector from "./wizard-mapper-connector";
import WizardMapperPair from "./wizard-mapper-pair";
import WizardMapperSelector from "./wizard-mapper-selector";

export default class extends Component {
  classNameBindings = [":mapper-input", "inputType"];
  @alias("input.type") inputType;
  @equal("inputType", "conditional") isConditional;
  @equal("inputType", "assignment") isAssignment;
  @equal("inputType", "association") isAssociation;
  @equal("inputType", "validation") isValidation;
  @or("isConditional", "isAssignment") hasOutput;
  @or("isConditional", "isAssociation", "isValidation") hasPairs;
  @not("isAssignment") canAddPair;
  @computed()
  get connectors() {
    return connectorContent("output", this.input.type, this.options);
  }
  @computed()
  get inputTypes() {
    return inputTypesContent(this.options);
  }

  @observes("input.type")
  setupType() {
    if (this.hasPairs && (!this.input.pairs || this.input.pairs.length < 1)) {
      this.send("addPair");
    }

    if (this.hasOutput) {
      this.set("input.output", null);

      if (!this.input.outputConnector) {
        const options = this.options;
        this.set("input.output_type", defaultSelectionType("output", options));
        this.set(
          "input.output_connector",
          defaultConnector("output", this.inputType, options)
        );
      }
    }
  }

  @action
  addPair() {
    if (!this.input.pairs) {
      this.set("input.pairs", A());
    }

    const pairs = this.input.pairs;
    const pairCount = pairs.length + 1;

    pairs.forEach((p) => set(p, "pairCount", pairCount));

    pairs.pushObject(
      newPair(
        this.input.type,
        Object.assign({}, this.options, { index: pairs.length, pairCount })
      )
    );
  }

  @action
  removePair(pair) {
    const pairs = this.input.pairs;
    const pairCount = pairs.length - 1;

    pairs.forEach((p) => set(p, "pairCount", pairCount));
    pairs.removeObject(pair);
  }
<template><WizardMapperConnector @connector={{this.input.type}} @connectors={{this.inputTypes}} @inputTypes={{true}} @inputType={{this.inputType}} @connectorType="type" @options={{this.options}} @onUpdate={{this.onUpdate}} />

{{#if this.hasPairs}}
  <div class="mapper-pairs mapper-block">
    {{#each this.input.pairs as |pair|}}
      <WizardMapperPair @pair={{pair}} @last={{pair.last}} @inputType={{this.inputType}} @options={{this.options}} @removePair={{this.removePair}} @onUpdate={{this.onUpdate}} />
    {{/each}}

    {{#if this.canAddPair}}
      <a role="button" {{on "click" this.addPair}} class="add-pair">
        {{icon "plus"}}
      </a>
    {{/if}}
  </div>
{{/if}}

{{#if this.hasOutput}}
  {{#if this.hasPairs}}
    <WizardMapperConnector @connector={{this.input.output_connector}} @connectors={{this.connectors}} @connectorType="output" @inputType={{this.inputType}} @options={{this.options}} @onUpdate={{this.onUpdate}} />
  {{/if}}

  <div class="output mapper-block">
    <WizardMapperSelector @selectorType="output" @inputType={{this.input.type}} @value={{this.input.output}} @activeType={{this.input.output_type}} @options={{this.options}} @onUpdate={{this.onUpdate}} />
  </div>
{{/if}}

<a role="button" class="remove-input" {{on "click" (fn this.remove this.input)}}>
  {{icon "xmark"}}
</a></template>}
