import Component from "@ember/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { computed } from "@ember/object";
import { alias, gt } from "@ember/object/computed";
import { connectorContent } from "../lib/wizard-mapper";
import wizardMapperSelector from "./wizard-mapper-selector";
import wizardMapperConnector from "./wizard-mapper-connector";
import icon from "discourse/helpers/d-icon";

export default class extends Component {
  classNameBindings = [":mapper-pair", "hasConnector::no-connector"];
  @gt("pair.index", 0) firstPair;
  @alias("firstPair") showRemove;
  @computed("pair.pairCount")
  get showJoin() {
    return this.pair.index < this.pair.pairCount - 1;
  }
  @computed()
  get connectors() {
    return connectorContent("pair", this.inputType, this.options);
  }
<template><div class="key mapper-block">
  {{wizardMapperSelector selectorType="key" inputType=this.inputType value=this.pair.key activeType=this.pair.key_type options=this.options onUpdate=this.onUpdate}}
</div>

{{wizardMapperConnector connector=this.pair.connector connectors=this.connectors connectorType="pair" inputType=this.inputType options=this.options onUpdate=this.onUpdate}}

<div class="value mapper-block">
  {{wizardMapperSelector selectorType="value" inputType=this.inputType value=this.pair.value activeType=this.pair.value_type options=this.options onUpdate=this.onUpdate connector=this.pair.connector}}
</div>

{{#if this.showJoin}}
  <span class="join-pair">&</span>
{{/if}}

{{#if this.showRemove}}
  <a role="button" {{on "click" (fn this.removePair this.pair)}} class="remove-pair">{{icon "xmark"}}</a>
{{/if}}</template>}
