import Component from "@ember/component";
import { dasherize } from "@ember/string";
import { htmlSafe } from "@ember/template";
import { cook } from "discourse/lib/text";
import discourseComputed from "discourse-common/utils/decorators";
import htmlSafeHelper from "discourse/helpers/html-safe";
import FieldValidators from "./field-validators";
import wizardCharCounter from "../helpers/wizard-char-counter";
import CustomWizardFieldText from "./custom-wizard-field-text";
import CustomWizardFieldTextarea from "./custom-wizard-field-textarea";
import CustomWizardFieldNumber from "./custom-wizard-field-number";
import CustomWizardFieldCheckbox from "./custom-wizard-field-checkbox";
import CustomWizardFieldUrl from "./custom-wizard-field-url";
import CustomWizardFieldUpload from "./custom-wizard-field-upload";
import CustomWizardFieldDropdown from "./custom-wizard-field-dropdown";
import CustomWizardFieldTag from "./custom-wizard-field-tag";
import CustomWizardFieldCategory from "./custom-wizard-field-category";
import CustomWizardFieldGroup from "./custom-wizard-field-group";
import CustomWizardFieldTopic from "./custom-wizard-field-topic";
import CustomWizardFieldDate from "./custom-wizard-field-date";
import CustomWizardFieldDateTime from "./custom-wizard-field-date-time";
import CustomWizardFieldTime from "./custom-wizard-field-time";
import CustomWizardFieldEmail from "./custom-wizard-field-email";
import CustomWizardFieldUserSelector from "./custom-wizard-field-user-selector";
import CustomWizardFieldComposer from "./custom-wizard-field-composer";
import CustomWizardFieldComposerPreview from "./custom-wizard-field-composer-preview";

const FIELD_COMPONENTS = {
  "text": CustomWizardFieldText,
  "textarea": CustomWizardFieldTextarea,
  "number": CustomWizardFieldNumber,
  "checkbox": CustomWizardFieldCheckbox,
  "url": CustomWizardFieldUrl,
  "upload": CustomWizardFieldUpload,
  "dropdown": CustomWizardFieldDropdown,
  "tag": CustomWizardFieldTag,
  "category": CustomWizardFieldCategory,
  "group": CustomWizardFieldGroup,
  "topic": CustomWizardFieldTopic,
  "date": CustomWizardFieldDate,
  "date_time": CustomWizardFieldDateTime,
  "time": CustomWizardFieldTime,
  "email": CustomWizardFieldEmail,
  "user_selector": CustomWizardFieldUserSelector,
  "composer": CustomWizardFieldComposer,
  "composer_preview": CustomWizardFieldComposerPreview,
};

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
  inputComponent(type, id) {
    if (["text_only"].includes(type)) {
      return false;
    }
    return FIELD_COMPONENTS[type] || false;
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
      {{#if this.inputComponent}}
        <div class="input-area">
          {{component
            this.inputComponent
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
