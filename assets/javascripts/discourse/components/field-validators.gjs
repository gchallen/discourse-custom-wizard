import Component from "@ember/component";
import { action } from "@ember/object";
import { hash } from "@ember/helper";
import SimilarTopicsValidator from "./similar-topics-validator";
import WizardRealtimeValidations from "./wizard-realtime-validations";

const VALIDATION_COMPONENTS = {
  "similar-topics-validator": SimilarTopicsValidator,
  "wizard-realtime-validations": WizardRealtimeValidations,
};

export default class FieldValidators extends Component {
  @action
  perform() {
    this.appEvents.trigger("custom-wizard:validate");
  }

  lookupComponent(name) {
    return VALIDATION_COMPONENTS[name] || name;
  }

  <template>
    {{#if this.field.validations}}
      {{#each-in this.field.validations.above as |type validation|}}
        {{component
          (this.lookupComponent validation.component)
          field=this.field
          type=type
          validation=validation
        }}
      {{/each-in}}

      {{yield (hash perform=this.perform autocomplete="off")}}

      {{#each-in this.field.validations.below as |type validation|}}
        {{component
          (this.lookupComponent validation.component)
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
