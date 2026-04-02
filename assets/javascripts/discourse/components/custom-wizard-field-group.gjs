import Component from "@ember/component";
import { mut } from "discourse/helpers/mut";
import customWizardGroupSelector from "./custom-wizard-group-selector";
import { hash, fn } from "@ember/helper";

export default class extends Component {<template>{{customWizardGroupSelector groups=this.site.groups class=this.fieldClass field=this.field whitelist=this.field.content value=this.field.value tabindex=this.field.tabindex onChange=(fn (mut this.field.value)) options=(hash none="select_kit.default_header_text")}}</template>}
