import Component, { Input } from "@ember/component";

export default class extends Component {<template><Input id={{this.field.id}} @type="checkbox" @checked={{this.field.value}} tabindex={{this.field.tabindex}} class={{this.fieldClass}} /></template>}
