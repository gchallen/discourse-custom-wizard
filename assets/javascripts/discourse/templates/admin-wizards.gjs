import RouteTemplate from 'ember-route-template'
import PluginOutlet from "discourse/components/plugin-outlet";
import WizardSubscriptionStatus from "../components/wizard-subscription-status";
import NavItem from "discourse/components/nav-item";
export default RouteTemplate(<template><PluginOutlet @name="admin-wizards-top" @connectorTagName="div" />

<WizardSubscriptionStatus />

<div class="admin-controls">
  <nav>
    <ul class="nav nav-pills">
      <NavItem @route="adminWizardsWizard" @label="admin.wizard.nav_label" />
      <NavItem @route="adminWizardsCustomFields" @label="admin.wizard.custom_field.nav_label" />
      <NavItem @route="adminWizardsSubmissions" @label="admin.wizard.submissions.nav_label" />
      {{#if @controller.showApi}}
        <NavItem @route="adminWizardsApi" @label="admin.wizard.api.nav_label" />
      {{/if}}
      <NavItem @route="adminWizardsLogs" @label="admin.wizard.log.nav_label" />
      <NavItem @route="adminWizardsManager" @label="admin.wizard.manager.nav_label" />
    </ul>
  </nav>
</div>

<div class="admin-container">
  {{outlet}}
</div></template>)
