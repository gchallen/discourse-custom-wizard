import TimeInput from "discourse/components/time-input";
import comboBox from "select-kit/components/combo-box";
import { hash } from "@ember/helper";

export default class extends TimeInput {<template>{{comboBox value=this.time content=this.timeOptions tabindex=this.tabindex onChange=(action "onChangeTime") options=(hash translatedNone="--:--" allowAny=true filterable=false autoInsertNoneItem=false translatedFilterPlaceholder="--:--")}}</template>}
