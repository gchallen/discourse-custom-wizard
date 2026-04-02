import { computed } from "@ember/object";
import { makeArray } from "discourse-common/lib/helpers";
import CategorySelector from "select-kit/components/category-selector";

class CustomWizardCategorySelector extends CategorySelector {
  classNames = ["category-selector", "wizard-category-selector"];
}

CustomWizardCategorySelector.reopen({
  content: computed(
    "categoryIds.[]",
    "blacklist.[]",
    "whitelist.[]",
    function () {
      return this._super().filter((category) => {
        const whitelist = makeArray(this.whitelist);
        return !whitelist.length || whitelist.indexOf(category.id) > -1;
      });
    }
  ),
});

export default CustomWizardCategorySelector;
