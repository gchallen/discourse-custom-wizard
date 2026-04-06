import Component from "@ember/component";
import { mut } from "discourse/helpers/mut";
import Category from "discourse/models/category";
import { observes } from "@ember-decorators/object";
import customWizardCategorySelector from "./custom-wizard-category-selector";
import { hash, fn } from "@ember/helper";
import CustomWizardCategorySelector from "./custom-wizard-category-selector";

export default class extends Component {
  categories = [];

  didInsertElement() {
    super.didInsertElement(...arguments);
    const property = this.field.property || "id";
    const value = this.field.value;

    if (value) {
      this.set(
        "categories",
        Array.from(value || []).reduce((result, v) => {
          let val =
            property === "id" ? Category.findById(v) : Category.findBySlug(v);
          if (val) {
            result.push(val);
          }
          return result;
        }, [])
      );
    }
  }

  @observes("categories")
  setValue() {
    const categories = (this.categories || []).filter((c) => !!c);
    const property = this.field.property || "id";

    if (categories.length) {
      this.set(
        "field.value",
        categories.reduce((result, c) => {
          if (c && c[property]) {
            result.push(c[property]);
          }
          return result;
        }, [])
      );
    }
  }
<template><CustomWizardCategorySelector @categories={{this.categories}} class={{this.fieldClass}} @whitelist={{this.field.content}} @onChange={{(fn (mut this.categories))}} @tabindex={{this.field.tabindex}} @options={{(hash maximum=this.field.limit)}} /></template>}
