import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { gt } from "@ember/object/computed";
import { later } from "@ember/runloop";
import I18n from "I18n";
import { defaultConnector } from "../lib/wizard-mapper";
import comboBox from "select-kit/components/combo-box";
import ComboBox from "select-kit/components/combo-box";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings(":mapper-connector", ":mapper-block", "hasMultiple::single")
export default class extends Component {
  @gt("connectors.length", 1) hasMultiple;
  @computed()
  get connectorLabel() {
    let key = this.connector;
    let path = this.inputTypes ? `input.${key}.name` : `connector.${key}`;
    return I18n.t(`admin.wizard.${path}`);
  }

  didReceiveAttrs() {
    super.didReceiveAttrs();
    if (!this.connector) {
      later(() => {
        this.set(
          "connector",
          defaultConnector(this.connectorType, this.inputType, this.options)
        );
      });
    }
  }

  @action
  changeConnector(value) {
    this.set("connector", value);
    this.onUpdate("connector", this.connectorType);
  }
<template>{{#if this.hasMultiple}}
  <ComboBox @value={{this.connector}} @content={{this.connectors}} @onChange={{this.changeConnector}} />
{{else}}
  {{#if this.connector}}
    <span class="connector-single">
      {{this.connectorLabel}}
    </span>
  {{/if}}
{{/if}}</template>}
