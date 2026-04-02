import Component from "@ember/component";
import customWizardGroupSelector from "./custom-wizard-group-selector";
import { hash } from "@ember/helper";

export default class extends Component {<template>{{customWizardGroupSelector groups=this.site.groups class=this.fieldClass field=this.field whitelist=this.field.content value=this.field.value tabindex=this.field.tabindex onChange=(action (mut this.field.value)) options=(hash none="select_kit.default_header_text")}}</template>}
