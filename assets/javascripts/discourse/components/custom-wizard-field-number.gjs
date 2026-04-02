import Component, { Input } from "@ember/component";

export default class extends Component {<template><Input id={{this.field.id}} step="0.01" @type="number" @value={{this.field.value}} tabindex={{this.field.tabindex}} class={{this.fieldClass}} /></template>}
