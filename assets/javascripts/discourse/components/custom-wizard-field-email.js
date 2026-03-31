import Component from "@ember/component";
import { observes } from "discourse-common/utils/decorators";

export default Component.extend({
  classNameBindings: [":wizard-field-email", "emailInvalid:invalid"],
  emailInvalid: false,

  keyPress(e) {
    e.stopPropagation();
  },

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
  },
});
