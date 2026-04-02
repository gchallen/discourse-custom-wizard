import navItem from "discourse/components/nav-item";
import icon from "discourse/helpers/d-icon";

<template>
{{#if this.currentUser.admin}}
  {{navItem route="adminWizards" label="admin.wizard.nav_label"}}

  {{#if this.wizardErrorNotice}}
    {{icon "exclaimation-circle"}}
  {{/if}}
{{/if}}
</template>
