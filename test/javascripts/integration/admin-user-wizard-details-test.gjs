import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import PluginOutlet from "discourse/components/plugin-outlet";
import lazyHash from "discourse/helpers/lazy-hash";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";

// Regression test for the production crash on the admin user page
// (/admin/users/:id/:username) for users flagged for onboarding redirect.
//
// The admin-user-details connector renders {{dasherize @model.redirect_to_wizard}}
// only when redirect_to_wizard is set (i.e. for non-onboarded users). Core's
// `dasherize` helper is a default-only export, so a NAMED `{ dasherize }` import
// resolved to `undefined`, and invoking the undefined helper threw
// `getPrototypeOf(undefined)` during the outlet render — corrupting the Glimmer
// render tree and locking up the whole admin page. The fix imports `dasherize`
// as a default export of d-dasherize.
module("Integration | Connector | admin-user-wizard-details", function (hooks) {
  setupRenderingTest(hooks);

  test("renders for a user flagged for wizard redirect without crashing", async function (assert) {
    const model = {
      redirect_to_wizard: "onboarding",
      clearWizardRedirect() {},
    };

    await render(
      <template>
        <PluginOutlet
          @name="admin-user-details"
          @outletArgs={{lazyHash model=model}}
        />
      </template>
    );

    assert
      .dom("section.details")
      .exists("the wizard-details section renders (no undefined-helper crash)");
    assert
      .dom("section.details a")
      .hasText("onboarding", "the redirect link renders (dasherize resolved)");
  });
});
