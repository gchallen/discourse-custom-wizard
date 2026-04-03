import RouteTemplate from 'ember-route-template'
import i18n from "discourse/helpers/i18n";
import dButton from "discourse/components/d-button";
import LoadMore from "discourse/components/load-more";
import wizardTableField from "../components/wizard-table-field";
import conditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import WizardTableField from "../components/wizard-table-field";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
export default RouteTemplate(<template>{{#if @controller.logs}}
  <div class="wizard-header large">
    <label>
      {{i18n "admin.wizard.log.title" name=@controller.wizard.name}}
    </label>

    <div class="controls">
      <DButton @label="refresh" @icon="arrows-rotate" @action={{this.refresh}} class="refresh" />
    </div>
  </div>

  <div class="wizard-table">
    {{#LoadMore selector=".wizard-table tr" action=this.loadMore}}
      {{#if @controller.noResults}}
        <p>{{i18n "search.no_results"}}</p>
      {{else}}
        <table>
          <thead>
            <tr>
              <th class="date">{{i18n "admin.wizard.log.date"}}</th>
              <th>{{i18n "admin.wizard.log.action"}}</th>
              <th>{{i18n "admin.wizard.log.user"}}</th>
              <th>{{i18n "admin.wizard.log.message"}}</th>
            </tr>
          </thead>
          <tbody>
            {{#each @controller.logs as |log|}}
              <tr>
                {{#each-in log as |field value|}}
                  <td class="small"><WizardTableField @field={{field}} @value={{value}} /></td>
                {{/each-in}}
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{/if}}

      <ConditionalLoadingSpinner @condition={{@controller.refreshing}} />
    {{/LoadMore}}
  </div>
{{/if}}</template>)
