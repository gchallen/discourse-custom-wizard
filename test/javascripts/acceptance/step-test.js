import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import {
  acceptance,
  count,
  exists,
  query,
  queryAll,
  visible,
} from "discourse/tests/helpers/qunit-helpers";
import { stepNotPermitted, update, wizard } from "../helpers/wizard";

acceptance("Step | Not permitted", function (needs) {
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(stepNotPermitted));
  });

  test("Shows not permitted message", async function (assert) {
    await visit("/w/wizard");
    assert.ok(exists(".step-message.not-permitted"));
  });
});

acceptance("Step | Step", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(wizard));
    server.put("/w/wizard/steps/:step_id", () => helper.response(update));
  });

  test("Renders the step", async function (assert) {
    await visit("/w/wizard");
    assert.strictEqual(
      query(".wizard-step-title p").textContent.trim(),
      "Text"
    );
    assert.ok(
      query(".wizard-step-description p").textContent.includes(
        "By joining, you agree to our"
      )
    );
    assert.strictEqual(count(".wizard-step-form .wizard-field"), 6);
    assert.ok(visible(".wizard-step-footer .wizard-progress"), true);
    assert.ok(visible(".wizard-step-footer .wizard-buttons"), true);
  });

  test("Step description links open in new tabs", async function (assert) {
    await visit("/w/wizard");
    const links = queryAll(".wizard-step-description a[href]");
    assert.ok(links.length > 0);
    links.each(function () {
      assert.strictEqual(this.getAttribute("target"), "_blank");
      assert.strictEqual(this.getAttribute("rel"), "noopener noreferrer");
    });
  });

  test("Field description links open in new tabs", async function (assert) {
    await visit("/w/wizard");
    const links = queryAll(".field-description a[href]");
    assert.ok(links.length > 0);
    links.each(function () {
      assert.strictEqual(this.getAttribute("target"), "_blank");
      assert.strictEqual(this.getAttribute("rel"), "noopener noreferrer");
    });
  });

  test("Goes to the next step", async function (assert) {
    await visit("/w/wizard");
    assert.ok(visible(".wizard-step.step_1"), true);
    await click(".wizard-btn.next");
    assert.ok(visible(".wizard-step.step_2"), true);
  });
});
