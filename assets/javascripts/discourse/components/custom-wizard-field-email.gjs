import Component, { Input } from "@ember/component";
import { observes } from "@ember-decorators/object";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings(":wizard-field-email", "emailInvalid:invalid")
export default class extends Component {
  emailInvalid = false;

  keyPress(e) {
    e.stopPropagation();
  }

  @observes("field.value")
  validateEmail() {
    const value = this.field.value;
    const allowedDomains = this.field.allowed_domains;

    if (!value || !allowedDomains) {
      this.set("emailInvalid", false);
      return;
    }

    const parts = value.trim().toLowerCase().split("@");
    if (parts.length !== 2 || !parts[1]) {
      this.set("emailInvalid", true);
      return;
    }

    const domain = parts[1];
    const allowed = allowedDomains.split("|").map((s) => s.trim());
    const isValid = allowed.some(
      (suffix) => domain === suffix || domain.endsWith(`.${suffix}`)
    );

    this.set("emailInvalid", !isValid);
  }
<template><Input id={{this.field.id}} @value={{this.field.value}} @type="email" tabindex={{this.field.tabindex}} class={{this.fieldClass}} placeholder={{this.field.translatedPlaceholder}} autocomplete="email" />
{{#if this.emailInvalid}}
  <div class="wizard-field-email-error">
    Please enter an email from an allowed domain.
  </div>
{{/if}}
</template>}
