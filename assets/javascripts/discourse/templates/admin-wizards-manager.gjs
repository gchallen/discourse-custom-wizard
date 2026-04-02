import RouteTemplate from 'ember-route-template'
import i18n from "discourse/helpers/i18n";
import icon from "discourse/helpers/d-icon";
import { Input } from "@ember/component";
import { on } from "@ember/modifier";
import dButton from "discourse/components/d-button";
import wizardMessage from "../components/wizard-message";
import dasherize from "discourse/helpers/dasherize";
import { LinkTo } from "@ember/routing";
export default RouteTemplate(<template><div class="admin-wizard-controls">
  <h3>{{i18n "admin.wizard.manager.title"}}</h3>

  <div class="buttons">
    {{#if @controller.filename}}
      <div class="filename">
        <a role="button" {{action "clearFile"}}>
          {{icon "xmark"}}
        </a>
        <span>{{@controller.filename}}</span>
      </div>
    {{/if}}

    <Input id="custom-wizard-file-upload" @type="file" accept="application/json" {{on "input" this.setFile}} />
    {{dButton id="upload-button" label="admin.wizard.manager.upload" action=this.upload}}
    {{dButton id="import-button" label="admin.wizard.manager.import" action=this.import disabled=@controller.importDisabled}}
    {{dButton id="export-button" label="admin.wizard.manager.export" action=this.export disabled=@controller.exportDisabled}}
    {{dButton id="destroy-button" label="admin.wizard.manager.destroy" action=this.destroy disabled=@controller.destoryDisabled}}
  </div>
</div>

{{wizardMessage key=@controller.messageKey url=@controller.messageUrl type=@controller.messageType opts=@controller.messageOpts items=@controller.messageItems loading=@controller.loading component="manager"}}

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
            <Input @type="checkbox" class="export" {{on "change" this.selectWizard}} />
          </td>
          <td class="control-column">
            <Input @type="checkbox" class="destroy" {{on "change" this.selectWizard}} />
          </td>
        </tr>
      {{/each}}
    </tbody>
  </table>
</div></template>)