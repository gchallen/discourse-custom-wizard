import Component from "@ember/component";
import { action } from "@ember/object";
import { hash } from "@ember/helper";

export default class FieldValidators extends Component {
  @action
  perform() {
    this.appEvents.trigger("custom-wizard:validate");
  }

  <template>
    {{#if this.field.validations}}
      {{#each-in this.field.validations.above as |type validation|}}
        {{component
          validation.component
          field=this.field
          type=type
          validation=validation
        }}
      {{/each-in}}

      {{yield (hash perform=this.perform autocomplete="off")}}

      {{#each-in this.field.validations.below as |type validation|}}
        {{component
          validation.component
          field=this.field
          type=type
          validation=validation
        }}
      {{/each-in}}
    {{else}}
      {{yield}}
    {{/if}}
  </template>
}
