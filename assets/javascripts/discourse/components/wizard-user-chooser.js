import { classNames, classNameBindings } from "@ember-decorators/component";
import I18n from "I18n";
import UserChooserComponent from "select-kit/components/user-chooser";
import { selectKitOptions } from "select-kit/components/select-kit";

export const WIZARD_USER = "wizard-user";

@classNames("user-chooser", "wizard-user-chooser")
@classNameBindings("selectKit.options.fullWidthWrap:full-width-wrap")
@selectKitOptions({
    fullWidthWrap: false,
    autoWrap: false,
  })
export default class extends UserChooserComponent {
  pluginApiIdentifiers = ["wizard-user-chooser"];


  valueProperty = "id";
  nameProperty = "name";

  modifyComponentForRow() {
    return "wizard-user-chooser/wizard-user-chooser-row";
  }

  modifyNoSelection() {
    return this.defaultItem(
      WIZARD_USER,
      I18n.t("admin.wizard.action.poster.wizard_user")
    );
  }



  search() {
    const superPromise = super.search(...arguments);
    if (!superPromise) {
      return;
    }
    return superPromise.then((results) => {
      if (!results || results.length === 0) {
        return;
      }
      return results.map((item) => {
        const reconstructed = {};
        if (item.username) {
          reconstructed.id = item.username;
          if (item.username.includes("@")) {
            reconstructed.isEmail = true;
          } else {
            reconstructed.isUser = true;
            reconstructed.name = item.name;
            reconstructed.showUserStatus = this.showUserStatus;
          }
        } else if (item.name) {
          reconstructed.id = item.name;
          reconstructed.name = item.full_name;
          reconstructed.isGroup = true;
        }
        return { ...item, ...reconstructed };
      });
    });
  }
}
