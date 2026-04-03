import RouteTemplate from 'ember-route-template'
import comboBox from "select-kit/components/combo-box";
import routeAction from "discourse/helpers/route-action";
import { hash } from "@ember/helper";
import wizardMessage from "../components/wizard-message";
export default RouteTemplate(<template><div class="admin-wizard-select admin-wizard-controls">
  {{comboBox value=@controller.wizardId content=@controller.wizardList onChange=(routeAction "changeWizard") options=(hash none="admin.wizard.select")}}
</div>

{{wizardMessage key=@controller.messageKey opts=@controller.messageOpts url=@controller.documentationUrl component="logs"}}

<div class="admin-wizard-container">
  {{outlet}}
</div></template>)
