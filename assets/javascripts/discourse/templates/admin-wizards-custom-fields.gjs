import RouteTemplate from 'ember-route-template'
import i18n from "discourse/helpers/i18n";
import dButton from "discourse/components/d-button";
import wizardMessage from "../components/wizard-message";
import { concat } from "@ember/helper";
import customFieldInput from "../components/custom-field-input";
import DButton from "discourse/components/d-button";
import WizardMessage from "../components/wizard-message";
import CustomFieldInput from "../components/custom-field-input";
export default RouteTemplate(<template><div class="admin-wizard-controls">
  <h3>{{i18n "admin.wizard.custom_field.nav_label"}}</h3>

  <div class="buttons">
    <DButton @label="admin.wizard.custom_field.add" @icon="plus" @action={{this.addField}} />
  </div>
</div>

<WizardMessage @key={{@controller.messageKey}} @opts={{@controller.messageOpts}} @type={{@controller.messageType}} @url={{@controller.documentationUrl}} @component="custom_fields" />

<div class="admin-wizard-container">
  {{#if @controller.customFields}}
    <table>
      <thead>
        <tr>
          {{#each @controller.fieldKeys as |key|}}
            <th>{{i18n (concat "admin.wizard.custom_field." key ".label")}}</th>
          {{/each}}
          <th></th>
        </tr>
      </thead>
      <tbody>
        {{#each @controller.customFields as |field|}}
          <CustomFieldInput @field={{field}} @removeField={{this.removeField}} @saveField={{this.saveField}} />
        {{/each}}
      </tbody>
    </table>
  {{/if}}
</div></template>)
