import RouteTemplate from 'ember-route-template'
import { on } from "@ember/modifier";
import i18n from "discourse/helpers/i18n";
import customWizardStep from "../components/custom-wizard-step";
export default RouteTemplate(<template>{{#if @controller.stepMessage}}
  <div class="step-message {{@controller.stepMessage.state}}">
    <div class="text">
      {{@controller.stepMessage.text}}
    </div>
    {{#if @controller.showReset}}
      <a role="button" class="reset-wizard" {{on "click" @controller.resetWizard}}>
        {{i18n "wizard.reset"}}
      </a>
    {{/if}}
  </div>
{{/if}}
{{#if @controller.step.permitted}}
  {{customWizardStep step=@controller.step wizard=@controller.wizard goNext=@controller.goNext goBack=@controller.goBack showMessage=@controller.showMessage}}
{{/if}}</template>)
