import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import I18n from "I18n";
import DButton from "discourse/components/d-button";
import loadingSpinner from "discourse/helpers/loading-spinner";
import icon from "discourse/helpers/d-icon";

export default class WizardSubscriptionBadge extends Component {
  @service subscription;
  @tracked updating = false;
  @tracked updateIcon = "arrows-rotate";
  basePath = "/admin/plugins/subscription-client";

  get i18nKey() {
    return `admin.wizard.subscription.type.${
      this.subscription.subscriptionType
        ? this.subscription.subscriptionType
        : "none"
    }`;
  }

  get title() {
    return `${this.i18nKey}.title`;
  }

  get label() {
    return I18n.t(`${this.i18nKey}.label`);
  }

  @action
  click() {
    window.open(this.subscription.subscriptionCtaLink, "_blank").focus();
  }

  @action
  update() {
    this.updating = true;
    this.updateIcon = null;
    this.subscription.updateSubscriptionStatus().finally(() => {
      this.updateIcon = "arrows-rotate";
      this.updating = false;
    });
  }
<template><DButton @icon={{this.updateIcon}} @action={{this.update}} class="btn update" @disabled={{this.updating}} @title="admin.wizard.subscription.update.title">
  {{#if this.updating}}
    {{loadingSpinner size="small"}}
  {{/if}}
</DButton>
<DButton @action={{this.click}} class="wizard-subscription-badge {{this.subscription.subscriptionType}}" @title={{this.title}}>
  {{icon "pavilion-logo"}}
  <span>{{this.label}}</span>
</DButton></template>}
