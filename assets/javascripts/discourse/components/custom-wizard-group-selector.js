import { computed } from "@ember/object";
import { makeArray } from "discourse-common/lib/helpers";
import ComboBox from "select-kit/components/combo-box";

export default class extends ComboBox {
  @computed("groups.[]", "field.content.[]")
  get content() {
    const whitelist = makeArray(this.field.content);
    return this.groups
      .filter((group) => {
        return !whitelist.length || whitelist.indexOf(group.id) > -1;
      })
      .map((g) => {
        return {
          id: g.id,
          name: g.full_name ? g.full_name : g.name,
        };
      });
  }
}
