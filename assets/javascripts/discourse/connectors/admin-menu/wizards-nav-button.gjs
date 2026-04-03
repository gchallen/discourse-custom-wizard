import navItem from "discourse/components/nav-item";
import icon from "discourse/helpers/d-icon";
import NavItem from "discourse/components/nav-item";

<template>
{{#if this.currentUser.admin}}
  <NavItem @route="adminWizards" @label="admin.wizard.nav_label" />

  {{#if this.wizardErrorNotice}}
    {{icon "exclaimation-circle"}}
  {{/if}}
{{/if}}
</template>
