import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse-common/lib/object";
import { acceptance, count, exists } from "discourse/tests/helpers/qunit-helpers";
import { wizard } from "../helpers/wizard";
import realFields from "../fixtures/onboarding-real-fields";

// Renders the ACTUAL production "onboarding" field set (checkboxes, textareas,
// a `text` field + `similar_topics` validation, the custom `email` field with
// allowed_domains, and a `url` field). The real fields are merged onto the
// known-good generic serialized wizard/step shape so the wizard renders exactly
// as the frontend would build it from /w/onboarding.json.
function realOnboarding() {
  const w = cloneJSON(wizard); // generic serialized wizard (permitted + user)
  const base = cloneJSON(w.steps[0].fields[0]); // a field with the full key set
  const step = cloneJSON(w.steps[0]);
  step.id = "step_1";
  step.fields = realFields.map((f, i) => ({
    ...cloneJSON(base),
    index: i,
    value: "",
    validations: {},
    tabindex: i + 1,
    ...cloneJSON(f),
  }));
  w.steps = [step];
  w.start = step.id;
  return w;
}

acceptance("Wizard | Real onboarding form", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(realOnboarding()));
  });

  test("renders the real onboarding form (9 fields) without crashing", async function (assert) {
    await visit("/w/wizard");
    assert.ok(
      exists(".wizard-column-contents .wizard-step"),
      "the onboarding step renders"
    );
    assert.strictEqual(
      count(".wizard-step-form .wizard-field"),
      9,
      "all 9 real fields render"
    );
    assert.ok(
      exists(".wizard-field.email-field input[type='email']"),
      "the custom email field renders"
    );
    assert.ok(exists(".wizard-field.url-field"), "the url field renders");
    assert.strictEqual(
      count(".wizard-field.checkbox-field"),
      2,
      "both required checkboxes render"
    );
    assert.strictEqual(
      count(".wizard-field.text-field"),
      2,
      "both similar_topics text fields render"
    );
  });
});
