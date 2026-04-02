import Component, { Input } from "@ember/component";

export default class extends Component {<template><Input id={{this.field.id}} @value={{this.field.value}} tabindex={{this.field.tabindex}} class={{this.fieldClass}} /></template>}
