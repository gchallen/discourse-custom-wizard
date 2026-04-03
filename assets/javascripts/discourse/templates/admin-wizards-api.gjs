import RouteTemplate from 'ember-route-template'
import comboBox from "select-kit/components/combo-box";
import routeAction from "discourse/helpers/route-action";
import { hash } from "@ember/helper";
import dButton from "discourse/components/d-button";
import ComboBox from "select-kit/components/combo-box";
import DButton from "discourse/components/d-button";
export default RouteTemplate(<template><div class="admin-wizard-controls">
  <ComboBox @value={{@controller.apiName}} @content={{@controller.apiList}} @onChange={{(routeAction "changeApi")}} @options={{(hash none="admin.wizard.api.select")}} />

  <DButton @action={{(routeAction "createApi")}} @label="admin.wizard.api.create" @icon="plus" />
</div>

<div class="admin-wizard-container">
  {{outlet}}
</div></template>)
