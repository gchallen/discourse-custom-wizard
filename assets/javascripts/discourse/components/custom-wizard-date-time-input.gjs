import DateTimeInput from "discourse/components/date-time-input";
import discourseComputed from "discourse-common/utils/decorators";
import customWizardDateInput from "./custom-wizard-date-input";
import customWizardTimeInput from "./custom-wizard-time-input";
import dButton from "discourse/components/d-button";
import CustomWizardDateInput from "./custom-wizard-date-input";
import CustomWizardTimeInput from "./custom-wizard-time-input";
import DButton from "discourse/components/d-button";

export default class extends DateTimeInput {
  @discourseComputed("timeFirst", "tabindex")
  timeTabindex(timeFirst, tabindex) {
    return timeFirst ? tabindex : tabindex + 1;
  }

  @discourseComputed("timeFirst", "tabindex")
  dateTabindex(timeFirst, tabindex) {
    return timeFirst ? tabindex + 1 : tabindex;
  }
<template>{{#unless this.timeFirst}}
  <CustomWizardDateInput @date={{this.date}} @relativeDate={{this.relativeDate}} @onChange={{this.onChangeDate}} @tabindex={{this.dateTabindex}} />
{{/unless}}

{{#if this.showTime}}
  <CustomWizardTimeInput @date={{this.date}} @relativeDate={{this.relativeDate}} @onChange={{this.onChangeTime}} @tabindex={{this.timeTabindex}} />
{{/if}}

{{#if this.timeFirst}}
  <CustomWizardDateInput @date={{this.date}} @relativeDate={{this.relativeDate}} @onChange={{this.onChangeDate}} @tabindex={{this.dateTabindex}} />
{{/if}}

{{#if this.clearable}}
  <DButton class="clear-date-time" @icon="xmark" @action={{this.onClear}} />
{{/if}}</template>}
