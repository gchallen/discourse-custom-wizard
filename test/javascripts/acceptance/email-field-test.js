import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse-common/lib/object";
import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { wizard } from "../helpers/wizard";

// Mirrors the production "onboarding" wizard, which uses the fork's custom
// `email` field type (with allowed_domains). The existing fixtures never
// exercise this field type, so the suite stayed green while the real form
// failed to render.
function wizardWithEmailField() {
  const w = cloneJSON(wizard);
  w.steps[0].fields.push({
    id: "step_1_field_email",
    index: 99,
    type: "email",
    required: true,
    value: "",
    label: "<p>Institutional Email</p>",
    description: "Your official university email address",
    allowed_domains: "edu|ac.uk|ca",
    validations: {},
    tabindex: 99,
    wizardId: "super_mega_fun_wizard",
    stepId: "step_1",
    _validState: 0,
  });
  w.start = "step_1";
  return w;
}

acceptance("Wizard | Email field (academic email)", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(wizardWithEmailField()));
  });

  test("renders the email field and the rest of the step", async function (assert) {
    await visit("/w/wizard");
    assert.ok(
      exists(".wizard-field.email-field input[type='email']"),
      "email field input renders"
    );
    assert.ok(
      exists(".wizard-column-contents .wizard-step"),
      "the wizard step still renders with an email field present"
    );
  });
});
