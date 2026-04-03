import RouteTemplate from 'ember-route-template'
import i18n from "discourse/helpers/i18n";
import icon from "discourse/helpers/d-icon";
import { Input } from "@ember/component";
import { on } from "@ember/modifier";
import dButton from "discourse/components/d-button";
import wizardMessage from "../components/wizard-message";
import dasherize from "discourse/helpers/dasherize";
import { LinkTo } from "@ember/routing";
import DButton from "discourse/components/d-button";
import WizardMessage from "../components/wizard-message";
export default RouteTemplate(<template><div class="admin-wizard-controls">
  <h3>{{i18n "admin.wizard.manager.title"}}</h3>

  <div class="buttons">
    {{#if @controller.filename}}
      <div class="filename">
        <a role="button" {{on "click" @controller.clearFile}}>
          {{icon "xmark"}}
        </a>
        <span>{{@controller.filename}}</span>
      </div>
    {{/if}}

    <Input id="custom-wizard-file-upload" @type="file" accept="application/json" {{on "input" @controller.setFile}} />
    <DButton @id="upload-button" @label="admin.wizard.manager.upload" @action={{@controller.upload}} />
    <DButton @id="import-button" @label="admin.wizard.manager.import" @action={{@controller.import}} @disabled={{@controller.importDisabled}} />
    <DButton @id="export-button" @label="admin.wizard.manager.export" @action={{@controller.export}} @disabled={{@controller.exportDisabled}} />
    <DButton @id="destroy-button" @label="admin.wizard.manager.destroy" @action={{@controller.destroy}} @disabled={{@controller.destoryDisabled}} />
  </div>
</div>

<WizardMessage @key={{@controller.messageKey}} @url={{@controller.messageUrl}} @type={{@controller.messageType}} @opts={{@controller.messageOpts}} @items={{@controller.messageItems}} @loading={{@controller.loading}} @component="manager" />

<div class="admin-wizard-container">
  <table class="table grid">
    <thead>
      <tr>
        <th>{{i18n "admin.wizard.label"}}</th>
        <th class="control-column">{{i18n "admin.wizard.manager.export"}}</th>
        <th class="control-column">{{i18n "admin.wizard.manager.destroy"}}</th>
      </tr>
    </thead>
    <tbody>
      {{#each @controller.wizards as |wizard|}}
        <tr data-wizard-id={{dasherize wizard.id}}>
          <td>
            <LinkTo @route="adminWizardsWizardShow" @model={{dasherize wizard.id}}>
              {{wizard.name}}
            </LinkTo>
          </td>
          <td class="control-column">
            <Input @type="checkbox" class="export" {{on "change" @controller.selectWizard}} />
          </td>
          <td class="control-column">
            <Input @type="checkbox" class="destroy" {{on "change" @controller.selectWizard}} />
          </td>
        </tr>
      {{/each}}
    </tbody>
  </table>
</div></template>)
