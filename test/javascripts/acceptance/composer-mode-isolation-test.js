import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance(
  "Composer | Plugin does not override mode for non-wizard composers",
  function (needs) {
    needs.user();
    needs.settings({
      rich_editor: true,
      allow_uncategorized_topics: true,
      custom_wizard_enabled: true,
    });

    test("regular new-topic composer respects user markdown preference", async function (assert) {
      await visit("/new-topic");

      assert
        .dom("textarea.d-editor-input")
        .exists("regular composer renders the textarea editor");

      assert
        .dom(".composer-toggle-switch.--markdown")
        .exists(
          "toggle reflects markdown preference (plugin does not force " +
            "CustomWizardTextareaEditor on non-wizard d-editors)"
        );

      assert
        .dom(".composer-toggle-switch.--rte")
        .doesNotExist("toggle is not stuck in rich-on state");
    });
  }
);
