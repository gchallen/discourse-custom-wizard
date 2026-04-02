import RouteTemplate from 'ember-route-template'
import ComboBox from "select-kit/components/combo-box";
import routeAction from "discourse/helpers/route-action";
import { hash } from "@ember/helper";
import DButton from "discourse/components/d-button";
import WizardMessage from "../components/wizard-message";
export default RouteTemplate(<template><div class="admin-wizard-controls">
  <ComboBox @value={{@controller.wizardListVal}} @content={{@controller.wizardList}} @onChange={{routeAction "changeWizard"}} @options={{hash none="admin.wizard.select"}} />
  <DButton @action={{routeAction "createWizard"}} @label="admin.wizard.create" @icon="plus" />
</div>

<WizardMessage @key={{@controller.messageKey}} @url={{@controller.messageUrl}} @component="wizard" />

<div class="admin-wizard-container settings">
  {{outlet}}
</div></template>)