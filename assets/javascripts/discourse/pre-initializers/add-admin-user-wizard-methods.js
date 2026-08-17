import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { withPluginApi } from "discourse/lib/plugin-api";

// The admin user page (connector: admin-user-details) exposes a button to
// clear a user's pending wizard redirect. Core migrated store models to native
// classes, so `api.modifyClass("model:admin-user", ...)` is deprecated
// (discourse.modify-class-model); use the dedicated model APIs instead. Model
// methods must be registered from a pre-initializer, before the model is first
// looked up.
export default {
  name: "custom-wizard-admin-user-methods",

  initialize() {
    withPluginApi("1.0", (api) => {
      api.addModelMethod("admin-user", "clearWizardRedirect", function (user) {
        return ajax(`/admin/users/${user.id}/wizards/clear_redirect`, {
          type: "PUT",
        })
          .then(() => {
            user.setProperties({
              redirect_to_wizard: null,
            });
          })
          .catch(popupAjaxError);
      });
    });
  },
};
