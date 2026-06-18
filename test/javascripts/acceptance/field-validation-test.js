import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse-common/lib/object";
import { acceptance, exists, query } from "discourse/tests/helpers/qunit-helpers";
import { wizard } from "../helpers/wizard";

acceptance("Field | Client-side validation messages", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    const requiredWizard = cloneJSON(wizard);
    // step_1_field_1 is a text field; make it required AND empty so leaving it
    // blank fails client-side validation when advancing. (The fixture ships it
    // prefilled, which would otherwise satisfy the required check.)
    const field = requiredWizard.steps[0].fields[0];
    field.required = true;
    field.value = "";
    server.get("/w/wizard.json", () => helper.response(requiredWizard));
  });

  test("surfaces a message to the user when a required field is empty", async function (assert) {
    await visit("/w/wizard");

    // Advance without filling the required field; validation should block here
    // (no step PUT) and explain why.
    await click(".wizard-btn.next");

    assert.ok(
      exists(".wizard-step.step_1"),
      "stays on the first step instead of advancing"
    );
    assert.ok(
      exists(".wizard-field.text-field.invalid"),
      "marks the required field as invalid"
    );
    assert.ok(
      exists(".wizard-field.text-field .field-error-description"),
      "renders an error description element for the field"
    );
    assert.ok(
      query(
        ".wizard-field.text-field .field-error-description"
      ).textContent.trim().length > 0,
      "the error description tells the user what is wrong"
    );
  });
});
