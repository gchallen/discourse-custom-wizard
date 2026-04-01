import Component from "@ember/component";
import { dasherize } from "@ember/string";
import { htmlSafe } from "@ember/template";
import { cook } from "discourse/lib/text";
import discourseComputed from "discourse-common/utils/decorators";

function openLinksInNewTab(html) {
  const div = document.createElement("div");
  div.innerHTML = html;
  div.querySelectorAll("a[href]").forEach((a) => {
    a.setAttribute("target", "_blank");
    a.setAttribute("rel", "noopener noreferrer");
  });
  return htmlSafe(div.innerHTML);
}

export default Component.extend({
  classNameBindings: [
    ":wizard-field",
    "typeClasses",
    "field.invalid",
    "field.id",
  ],

  didReceiveAttrs() {
    this._super(...arguments);

    cook(this.field.translatedDescription).then((cookedDescription) => {
      this.set("cookedDescription", openLinksInNewTab(cookedDescription));
    });
  },

  @discourseComputed("field.type", "field.id")
  typeClasses: (type, id) =>
    `${dasherize(type)}-field ${dasherize(type)}-${dasherize(id)}`,

  @discourseComputed("field.id")
  fieldClass: (id) => `field-${dasherize(id)} wizard-focusable`,

  @discourseComputed("field.type", "field.id")
  inputComponentName(type, id) {
    if (["text_only"].includes(type)) {
      return false;
    }
    return dasherize(type === "component" ? id : `custom-wizard-field-${type}`);
  },

  @discourseComputed("field.type")
  textType(fieldType) {
    return ["text", "textarea"].includes(fieldType);
  },
});
