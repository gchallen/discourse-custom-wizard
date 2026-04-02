import Component from "@ember/component";
import { dasherize } from "@ember/string";
import { htmlSafe } from "@ember/template";
import { cook } from "discourse/lib/text";
import discourseComputed from "discourse-common/utils/decorators";
import htmlSafeHelper from "discourse/helpers/html-safe";
import FieldValidators from "./field-validators";
import wizardCharCounter from "../helpers/wizard-char-counter";

function openLinksInNewTab(html) {
  const div = document.createElement("div");
  div.innerHTML = html;
  div.querySelectorAll("a[href]").forEach((a) => {
    a.setAttribute("target", "_blank");
    a.setAttribute("rel", "noopener noreferrer");
  });
  return htmlSafe(div.innerHTML);
}

export default class CustomWizardField extends Component {
  classNameBindings = [
    ":wizard-field",
    "typeClasses",
    "field.invalid",
    "field.id",
  ];

  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    cook(this.field.translatedDescription).then((cookedDescription) => {
      this.set("cookedDescription", openLinksInNewTab(cookedDescription));
    });
  }

  @discourseComputed("field.type", "field.id")
  typeClasses(type, id) {
    return `${dasherize(type)}-field ${dasherize(type)}-${dasherize(id)}`;
  }

  @discourseComputed("field.id")
  fieldClass(id) {
    return `field-${dasherize(id)} wizard-focusable`;
  }

  @discourseComputed("field.type", "field.id")
  inputComponentName(type, id) {
    if (["text_only"].includes(type)) {
      return false;
    }
    return dasherize(type === "component" ? id : `custom-wizard-field-${type}`);
  }

  @discourseComputed("field.type")
  textType(fieldType) {
    return ["text", "textarea"].includes(fieldType);
  }

  <template>
    <label for={{this.field.id}} class="field-label">
      {{htmlSafeHelper this.field.translatedLabel}}
    </label>

    {{#if this.field.image}}
      <div class="field-image"><img src={{this.field.image}} /></div>
    {{/if}}

    {{#if this.field.description}}
      <div class="field-description">{{this.cookedDescription}}</div>
    {{/if}}

    <FieldValidators @field={{this.field}} as |validators|>
      {{#if this.inputComponentName}}
        <div class="input-area">
          {{component
            this.inputComponentName
            field=this.field
            step=this.step
            fieldClass=this.fieldClass
            wizard=this.wizard
            autocomplete=validators.autocomplete
          }}
        </div>
      {{/if}}
    </FieldValidators>

    {{#if this.field.char_counter}}
      {{#if this.textType}}
        {{wizardCharCounter this.field.value this.field.max_length}}
      {{/if}}
    {{/if}}

    {{#if this.field.errorDescription}}
      <div class="field-error-description">{{htmlSafeHelper
          this.field.errorDescription
        }}</div>
    {{/if}}
  </template>
}
