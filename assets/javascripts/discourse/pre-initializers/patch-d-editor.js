import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "custom-wizard-patch-d-editor",
  before: "inject-discourse-objects",

  initialize() {
    withPluginApi("1.0", (api) => {
      api.modifyClass("component:d-editor", {
        pluginId: "custom-wizard-d-editor-patch",

        async setupEditorMode() {
          if (!this.currentUser) {
            return;
          }
          return this._super(...arguments);
        },
      });
    });
  },
};
