import { makeArray } from "discourse-common/lib/helpers";
import TagChooser from "select-kit/components/tag-chooser";

export default class extends TagChooser {
  _transformJson(context, json) {
    return super._transformJson(context, json).filter((tag) => {
      const whitelist = makeArray(context.whitelist);
      return !whitelist.length || whitelist.indexOf(tag.id) > 1;
    });
  }
}
