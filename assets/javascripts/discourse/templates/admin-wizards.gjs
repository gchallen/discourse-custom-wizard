import RouteTemplate from 'ember-route-template'
import PluginOutlet from "discourse/components/plugin-outlet";
import WizardSubscriptionStatus from "../components/wizard-subscription-status";
import AdminNav from "admin/components/admin-nav";
import navItem from "discourse/components/nav-item";
export default RouteTemplate(<template><PluginOutlet @name="admin-wizards-top" @connectorTagName="div" />

<WizardSubscriptionStatus />

{{#AdminNav}}
  {{navItem route="adminWizardsWizard" label="admin.wizard.nav_label"}}
  {{navItem route="adminWizardsCustomFields" label="admin.wizard.custom_field.nav_label"}}
  {{navItem route="adminWizardsSubmissions" label="admin.wizard.submissions.nav_label"}}
  {{#if @controller.showApi}}
    {{navItem route="adminWizardsApi" label="admin.wizard.api.nav_label"}}
  {{/if}}
  {{navItem route="adminWizardsLogs" label="admin.wizard.log.nav_label"}}
  {{navItem route="adminWizardsManager" label="admin.wizard.manager.nav_label"}}
{{/AdminNav}}

<div class="admin-container">
  {{outlet}}
</div></template>)