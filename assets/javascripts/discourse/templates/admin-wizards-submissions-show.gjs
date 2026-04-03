import RouteTemplate from 'ember-route-template'
import i18n from "discourse/helpers/i18n";
import dButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import LoadMore from "discourse/components/load-more";
import wizardTableField from "../components/wizard-table-field";
import conditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import WizardTableField from "../components/wizard-table-field";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
export default RouteTemplate(<template>{{#if @controller.submissions}}
  <div class="wizard-header large">
    <label>
      {{i18n "admin.wizard.submissions.title" name=@controller.wizard.name}}
    </label>

    <div class="controls">
      <DButton @icon="sliders" @label="admin.wizard.edit_columns" @action={{@controller.showEditColumnsModal}} class="btn-default open-edit-columns-btn download-link" />
    </div>

    <a class="btn btn-default download-link" href={{@controller.downloadUrl}} target="_blank" rel="noopener noreferrer">
      {{icon "download"}}
      <span class="d-button-label">
        {{i18n "admin.wizard.submissions.download"}}
      </span>
    </a>
  </div>

  <div class="wizard-table">
    {{#LoadMore selector=".wizard-table tr" action=this.loadMore}}
      {{#if @controller.noResults}}
        <p>{{i18n "search.no_results"}}</p>
      {{else}}
        <table>
          <thead>
            <tr>
              {{#each @controller.fields as |field|}}
                {{#if field.enabled}}
                  <th>
                    {{field.label}}
                  </th>
                {{/if}}
              {{/each}}
            </tr>
          </thead>
          <tbody>
            {{#each @controller.displaySubmissions as |submission|}}
              <tr>
                {{#each-in submission as |field value|}}
                  <td><WizardTableField @field={{field}} @value={{value}} /></td>
                {{/each-in}}
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{/if}}

      <ConditionalLoadingSpinner @condition={{@controller.loadingMore}} />
    {{/LoadMore}}
  </div>
{{/if}}</template>)
