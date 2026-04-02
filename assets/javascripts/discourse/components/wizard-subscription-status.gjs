import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import WizardSubscriptionBadge from "./wizard-subscription-badge";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import i18n from "discourse/helpers/i18n";

export default class WizardSubscriptionStatus extends Component {
  @service siteSettings;
  @service subscription;
  @tracked supplierId = null;
  @tracked authorized = false;
  @tracked unauthorizing = false;
  @tracked loaded = false;
  basePath = "/admin/plugins/subscription-client/suppliers";

  constructor() {
    super(...arguments);
    this._load();
  }

  async _load() {
    try {
      const result = await ajax(
        `${this.basePath}?resource=discourse-custom-wizard`
      );
      if (result.suppliers && result.suppliers.length) {
        this.supplierId = result.suppliers[0].id;
        this.authorized = result.suppliers[0].authorized;
      }
    } catch {
      // suppliers endpoint may not be available
    }

    await this.subscription.retrieveSubscriptionStatus();
    this.loaded = true;
  }

  @action
  authorize() {
    window.location.href = `${this.basePath}/authorize?supplier_id=${this.supplierId}&final_landing_path=/admin/wizards/wizard`;
  }

  @action
  deauthorize() {
    this.unauthorizing = true;

    ajax(`${this.basePath}/authorize`, {
      type: "DELETE",
      data: {
        supplier_id: this.supplierId,
      },
    })
      .then((result) => {
        if (result.success) {
          this.supplierId = result.supplier_id;
          this.authorized = false;
        }
      })
      .finally(() => {
        this.unauthorizing = false;
        this.subscription.retrieveSubscriptionStatus();
      })
      .catch(popupAjaxError);
  }
<template><div class="supplier-authorize">
  <WizardSubscriptionBadge />
  {{#if this.authorized}}
    <ConditionalLoadingSpinner @condition={{this.unauthorizing}} @size="small" />
    <DButton class="deauthorize" @title="admin.wizard.subscription.deauthorize.title" @disabled={{this.unauthorizing}} @action={{this.deauthorize}}>
      {{i18n "admin.wizard.subscription.deauthorize.label"}}
    </DButton>
  {{else}}
    <DButton @icon="id-card" class="btn-primary" @label="admin.wizard.subscription.authorize.label" @title="admin.wizard.subscription.authorize.title" @action={{this.authorize}} />
  {{/if}}
</div></template>}
