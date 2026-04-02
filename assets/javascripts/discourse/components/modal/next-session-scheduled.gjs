import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import I18n from "I18n";
import DModal from "discourse/components/d-modal";
import DateTimeInput from "discourse/components/date-time-input";
import DButton from "discourse/components/d-button";

export default class NextSessionScheduledComponent extends Component {
  @tracked bufferedDateTime;
  title = I18n.t("admin.wizard.after_time_modal.title");

  constructor() {
    super(...arguments);
    this.bufferedDateTime = this.args.model.dateTime
      ? moment(this.args.model.dateTime)
      : moment(Date.now());
  }

  get submitDisabled() {
    return moment().isAfter(this.bufferedDateTime);
  }

  @action
  submit() {
    const dateTime = this.bufferedDateTime;
    this.args.model.update(moment(dateTime).utc().toISOString());
    this.args.closeModal();
  }

  @action
  dateTimeChanged(dateTime) {
    this.bufferedDateTime = dateTime;
  }
<template><DModal @closeModal={{@closeModal}} class="next-session-time-modal" @title={{this.title}}>
  <DateTimeInput @date={{this.bufferedDateTime}} @onChange={{action "dateTimeChanged"}} @showTime="true" @clearable="true" />
  <div class="modal-footer">
    <DButton @action={{action "submit"}} class="btn-primary" @label="admin.wizard.after_time_modal.done" @disabled={{this.submitDisabled}} />
  </div>
</DModal></template>}
