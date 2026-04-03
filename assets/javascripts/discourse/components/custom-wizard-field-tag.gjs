import Component from "@ember/component";
import customWizardTagChooser from "./custom-wizard-tag-chooser";
import { hash } from "@ember/helper";
import CustomWizardTagChooser from "./custom-wizard-tag-chooser";

export default class extends Component {<template><CustomWizardTagChooser @tags={{this.field.value}} class={{this.fieldClass}} @tabindex={{this.field.tabindex}} @tagGroups={{this.field.tag_groups}} @everyTag={{true}} @options={{(hash maximum=this.field.limit allowAny=this.field.can_create_tag)}} /></template>}
