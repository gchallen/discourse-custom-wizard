import TimeInput from "discourse/components/time-input";
import comboBox from "select-kit/components/combo-box";
import { hash } from "@ember/helper";
import ComboBox from "select-kit/components/combo-box";

export default class extends TimeInput {<template><ComboBox @value={{this.time}} @content={{this.timeOptions}} @tabindex={{this.tabindex}} @onChange={{this.onChangeTime}} @options={{(hash translatedNone="--:--" allowAny=true filterable=false autoInsertNoneItem=false translatedFilterPlaceholder="--:--")}} /></template>}
