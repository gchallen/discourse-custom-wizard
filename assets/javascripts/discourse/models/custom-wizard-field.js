import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { i18n } from "discourse-i18n";
import { translationOrText } from "discourse/plugins/discourse-custom-wizard/discourse/lib/wizard";
import ValidState from "discourse/plugins/discourse-custom-wizard/discourse/mixins/valid-state";

const StandardFieldValidation = [
  "text",
  "number",
  "textarea",
  "dropdown",
  "tag",
  "image",
  "user_selector",
  "text_only",
  "composer",
  "category",
  "topic",
  "group",
  "date",
  "time",
  "date_time",
];

export default EmberObject.extend(ValidState, {
  id: null,
  type: null,
  value: null,
  required: null,

  @discourseComputed("wizardId", "stepId", "id")
  i18nKey(wizardId, stepId, id) {
    return `${wizardId}.${stepId}.${id}`;
  },

  @discourseComputed("i18nKey", "label")
  translatedLabel(i18nKey, label) {
    return translationOrText(`${i18nKey}.label`, label);
  },

  @discourseComputed("i18nKey", "placeholder")
  translatedPlaceholder(i18nKey, placeholder) {
    return translationOrText(`${i18nKey}.placeholder`, placeholder);
  },

  @discourseComputed("i18nKey", "description")
  translatedDescription(i18nKey, description) {
    return translationOrText(`${i18nKey}.description`, description);
  },

  check() {
    if (this.customCheck) {
      return this.customCheck();
    }

    if (!this.required) {
      this.setValid(true);
      return true;
    }

    const val = this.get("value");
    const type = this.get("type");
    let valid;
    // Default message covers empty required fields of every type.
    let errorKey = "required";

    if (type === "checkbox") {
      valid = val;
    } else if (type === "upload") {
      valid = val && val.id > 0;
    } else if (StandardFieldValidation.indexOf(type) > -1) {
      valid = val && val.toString().length > 0;
    } else if (type === "url") {
      valid = true;
    } else if (type === "email") {
      valid = val && val.toString().length > 0;
      if (valid && this.get("allowed_domains")) {
        const domain = val.trim().toLowerCase().split("@")[1];
        if (domain) {
          const allowed = this.get("allowed_domains").split("|").map((s) => s.trim());
          valid = allowed.some(
            (suffix) => domain === suffix || domain.endsWith(`.${suffix}`)
          );
        } else {
          valid = false;
        }
        if (!valid) {
          errorKey = "invalid_email";
        }
      }
    }

    valid = Boolean(valid);
    // Surface a human-readable reason to the user, not just a red field.
    this.setValid(valid, valid ? null : i18n(`wizard.field.${errorKey}`));

    return valid;
  },
});
