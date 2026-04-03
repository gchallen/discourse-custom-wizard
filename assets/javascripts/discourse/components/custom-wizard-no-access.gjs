import { getOwner } from "@ember/application";
import { on } from "@ember/modifier";
import Component from "@ember/component";
import { action } from "@ember/object";
import { dasherize } from "@ember/string";
import cookie from "discourse/lib/cookie";
import getURL from "discourse-common/lib/get-url";
import discourseComputed from "discourse-common/utils/decorators";
import CustomWizard from "../models/custom-wizard";
import i18n from "discourse/helpers/i18n";
import DButton from "discourse/components/d-button";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings(":wizard-no-access", "reasonClass")
export default class extends Component {

  @discourseComputed("reason")
  reasonClass(reason) {
    return dasherize(reason);
  }

  @discourseComputed
  siteName() {
    return this.siteSettings.title || "";
  }

  @discourseComputed("reason")
  showLoginButton(reason) {
    return reason === "requiresLogin";
  }

  @action
  skip() {
    if (this.currentUser) {
      CustomWizard.skip(this.get("wizardId"));
    } else {
      window.location = getURL("/");
    }
  }

  @action
  showLogin() {
    cookie("destination_url", getURL(`/w/${this.get("wizardId")}`));
    getOwner(this).lookup("route:application").send("showLogin");
  }
<template><div>{{this.text}}</div>
<div class="no-access-gutter">
  <a class="return-to-site" {{on "click" this.skip}} role="button">
    {{i18n "wizard.return_to_site" siteName=this.siteName}}
  </a>
  {{#if this.showLoginButton}}
    <DButton class="btn-primary btn-small login-button" @action={{on "click" this.showLogin}} @label="log_in" @icon="user" />
  {{/if}}
</div></template>}
