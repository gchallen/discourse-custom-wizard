import Component from "@glimmer/component";
import { action } from "@ember/object";
import { Input } from "@ember/component";
import I18n from "I18n";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import LoadingSpinner from "discourse/components/loading-spinner";
import directoryTableHeaderTitle from "discourse/helpers/directory-table-header-title";

export default class AdminWizardsColumnComponent extends Component {
  title = I18n.t("admin.wizard.edit_columns");

  @action
  save() {
    this.args.closeModal();
  }

  @action
  resetToDefault() {
    this.args.model.reset();
  }

  <template>
    <DModal @closeModal={{@closeModal}} @title={{this.title}}>
      {{#if this.loading}}
        <LoadingSpinner @size="large" />
      {{else}}
        <div class="edit-directory-columns-container">
          {{#each @model.columns as |column|}}
            <div class="edit-directory-column">
              <div class="left-content">
                <label class="column-name">
                  <Input @type="checkbox" @checked={{column.enabled}} />
                  {{directoryTableHeaderTitle
                    field=column.label
                    translated=true
                  }}
                </label>
              </div>
            </div>
          {{/each}}
        </div>
      {{/if}}
      <div class="modal-footer">
        <DButton
          class="btn-primary"
          @label="directory.edit_columns.save"
          @action={{this.save}}
        />

        <DButton
          class="btn-secondary reset-to-default"
          @label="directory.edit_columns.reset_to_default"
          @action={{this.resetToDefault}}
        />
      </div>
    </DModal>
  </template>
}
