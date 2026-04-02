import RouteTemplate from 'ember-route-template'
import CustomWizardNoAccess from "../components/custom-wizard-no-access";
import i18n from "discourse/helpers/i18n";
export default RouteTemplate(<template>{{#if @controller.noAccess}}
  <CustomWizardNoAccess @text={{i18n @controller.noAccessI18nKey}} @wizardId={{@controller.wizardId}} @reason={{@controller.noAccessReason}} />
{{/if}}</template>)