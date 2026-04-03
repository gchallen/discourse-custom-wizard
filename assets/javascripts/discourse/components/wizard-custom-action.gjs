import Component, { Input } from "@ember/component";
import { action } from "@ember/object";
import { mut } from "discourse/helpers/mut";
import { computed } from "@ember/object";
import { empty, equal, or } from "@ember/object/computed";
import { default as discourseComputed } from "discourse-common/utils/decorators";
import I18n from "I18n";
import { notificationLevels, selectKitContent } from "../lib/wizard";
import UndoChanges from "../mixins/undo-changes";
import dButton from "discourse/components/d-button";
import i18n from "discourse/helpers/i18n";
import wizardSubscriptionSelector from "./wizard-subscription-selector";
import { hash, fn } from "@ember/helper";
import comboBox from "select-kit/components/combo-box";
import wizardMessage from "./wizard-message";
import wizardMapper from "./wizard-mapper";
import wizardTextEditor from "./wizard-text-editor";
import DButton from "discourse/components/d-button";
import WizardSubscriptionSelector from "./wizard-subscription-selector";
import ComboBox from "select-kit/components/combo-box";
import WizardMessage from "./wizard-message";
import WizardMapper from "./wizard-mapper";
import WizardTextEditor from "./wizard-text-editor";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings(":wizard-custom-action", "visible")
export default class extends Component.extend(UndoChanges) {
  componentType = "action";
  @computed("currentActionId")
  get visible() {
    return this.action.id === this.currentActionId;
  }
  @equal("action.type", "create_topic") createTopic;
  @equal("action.type", "update_profile") updateProfile;
  @equal("action.type", "watch_categories") watchCategories;
  @equal("action.type", "watch_tags") watchTags;
  @equal("action.type", "send_message") sendMessage;
  @equal("action.type", "open_composer") openComposer;
  @equal("action.type", "send_to_api") sendToApi;
  @equal("action.type", "add_to_group") addToGroup;
  @equal("action.type", "route_to") routeTo;
  @equal("action.type", "create_category") createCategory;
  @equal("action.type", "create_group") createGroup;
  @empty("action.api") apiEmpty;
  groupPropertyTypes = selectKitContent(["id", "name"]);
  @or(
    "basicTopicFields",
    "updateProfile",
    "createGroup",
    "createCategory"
  ) hasCustomFields;
  @or("createTopic", "sendMessage", "openComposer") basicTopicFields;
  @or("createTopic", "openComposer") publicTopicFields;
  @or("createTopic", "sendMessage") showPostAdvanced;
  availableNotificationLevels = notificationLevels.map((type) => {
    return {
      id: type,
      name: I18n.t(`admin.wizard.action.watch_x.notification_level.${type}`),
    };
  });

  messageUrl =
    "https://pavilion.tech/products/discourse-custom-wizard-plugin/documentation/action-settings";

  @discourseComputed("action.type")
  messageKey(type) {
    let key = "type";
    if (type) {
      key = "edit";
    }
    return key;
  }

  @discourseComputed("action.type")
  customFieldsContext(type) {
    return `action.${type}`;
  }

  @discourseComputed("wizard.steps")
  runAfterContent(steps) {
    let content = steps.map(function (step) {
      return {
        id: step.id,
        name: step.title || step.id,
      };
    });

    content.unshift({
      id: "wizard_completion",
      name: I18n.t("admin.wizard.action.run_after.wizard_completion"),
    });

    return content;
  }

  @discourseComputed("apis")
  availableApis(apis) {
    return apis.map((a) => {
      return {
        id: a.name,
        name: a.title,
      };
    });
  }

  @discourseComputed("apis", "action.api")
  availableEndpoints(apis, api) {
    if (!api) {
      return [];
    }
    return apis.find((a) => a.name === api).endpoints;
  }

  @discourseComputed("fieldTypes")
  hasEventField(fieldTypes) {
    return fieldTypes.map((ft) => ft.id).includes("event");
  }

  @discourseComputed("fieldTypes")
  hasLocationField(fieldTypes) {
    return fieldTypes.map((ft) => ft.id).includes("location");
  }

  @action undoChanges() { super.undoChanges(...arguments); }
  @action changeType(type) { super.changeType(type); }
  @action mappedFieldUpdated(property, mappedComponent, type) { super.mappedFieldUpdated(property, mappedComponent, type); }

<template>{{#if this.showUndo}}
  <DButton @action={{this.undoChanges}} @icon={{this.undoIcon}} @label={{this.undoKey}} class="undo-changes" />
{{/if}}

<div class="setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.type"}}</label>
  </div>

  <div class="setting-value">
    <WizardSubscriptionSelector @value={{this.action.type}} @feature="action" @attribute="type" @onChange={{this.changeType}} @wizard={{this.wizard}} @options={{(hash none="admin.wizard.select_type")}} />
  </div>
</div>

<div class="setting">
  <div class="setting-label">
    <label>{{i18n "admin.wizard.action.run_after.label"}}</label>
  </div>

  <div class="setting-value">
    <ComboBox @value={{this.action.run_after}} @content={{this.runAfterContent}} @onChange={{(fn (mut this.action.run_after))}} />
  </div>
</div>

<WizardMessage @key={{this.messageKey}} @url={{this.messageUrl}} @component="action" />

{{#if this.basicTopicFields}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.title"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.title}} @property="title" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash wizardFieldSelection=true userFieldSelection="key,value" context="action")}} />
    </div>
  </div>

  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.post"}}</label>
    </div>

    <div class="setting-value">
      <ComboBox @value={{this.action.post}} @content={{this.wizardFields}} @nameProperty="label" @onChange={{(fn (mut this.action.post))}} @options={{(hash none="admin.wizard.selector.placeholder.wizard_field" isDisabled=this.showPostBuilder)}} />

      <div class="setting-gutter">
        <Input @type="checkbox" @checked={{this.action.post_builder}} />
        <span>{{i18n "admin.wizard.action.post_builder.checkbox"}}</span>
      </div>
    </div>
  </div>

  {{#if this.action.post_builder}}
    <div class="setting full">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.action.post_builder.label"}}</label>
      </div>

      <div class="setting-value editor">
        <WizardTextEditor @value={{this.action.post_template}} @wizardFields={{this.wizardFields}} />
      </div>
    </div>
  {{/if}}
{{/if}}

{{#if this.publicTopicFields}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_topic.category"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.category}} @property="category" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="key,value" wizardFieldSelection=true userFieldSelection="key,value" categorySelection="output" wizardActionSelection="output" outputDefaultSelection="category" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_topic.tags"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.tags}} @property="tags" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash tagSelection="output" outputDefaultSelection="tag" listSelection="output" wizardFieldSelection=true userFieldSelection="key,value" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_topic.visible"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.visible}} @property="visible" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>

  {{#if this.hasEventField}}
    <div class="setting full">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.action.create_topic.add_event"}}</label>
      </div>

      <div class="setting-value">
        <WizardMapper @inputs={{this.action.add_event}} @property="add_event" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash wizardFieldSelection=true context="action")}} />
      </div>
    </div>
  {{/if}}

  {{#if this.hasLocationField}}
    <div class="setting full">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.action.create_topic.add_location"}}</label>
      </div>

      <div class="setting-value">
        <WizardMapper @inputs={{this.action.add_location}} @property="add_location" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash wizardFieldSelection=true context="action")}} />
      </div>
    </div>
  {{/if}}
{{/if}}

{{#if this.sendMessage}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.send_message.recipient"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.recipient}} @property="recipient" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="value,output" wizardFieldSelection=true userFieldSelection="key,value" groupSelection="key,value" userSelection="output" outputDefaultSelection="user" context="action" includeMessageableGroups="true")}} />
    </div>
  </div>
{{/if}}

{{#if this.updateProfile}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.update_profile.setting"}}</label>
    </div>

    <WizardMapper @inputs={{this.action.profile_updates}} @property="profile_updates" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash inputTypes="association" textSelection="value" userFieldSelection="key" wizardFieldSelection="value" wizardActionSelection="value" keyDefaultSelection="userField" context="action")}} />
  </div>
{{/if}}

{{#if this.sendToApi}}
  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.send_to_api.api"}}</label>
    </div>

    <div class="setting-value">
      <ComboBox @value={{this.action.api}} @content={{this.availableApis}} @onChange={{(fn (mut this.action.api))}} @options={{(hash isDisabled=this.action.custom_title_enabled none="admin.wizard.action.send_to_api.select_an_api")}} />
    </div>
  </div>

  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.send_to_api.endpoint"}}</label>
    </div>

    <div class="setting-value">
      <ComboBox @value={{this.action.api_endpoint}} @content={{this.availableEndpoints}} @onChange={{(fn (mut this.action.api_endpoint))}} @options={{(hash isDisabled=this.apiEmpty none="admin.wizard.action.send_to_api.select_an_endpoint")}} />
    </div>
  </div>

  <div class="setting full">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.send_to_api.body"}}</label>
    </div>

    <div class="setting-value">
      <WizardTextEditor @value={{this.action.api_body}} @previewEnabled={{false}} @barEnabled={{false}} @wizardFields={{this.wizardFields}} @placeholder="admin.wizard.action.send_to_api.body_placeholder" />
    </div>
  </div>
{{/if}}

{{#if this.addToGroup}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.group"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.group}} @property="group" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="value,output" wizardFieldSelection="key,value,assignment" userFieldSelection="key,value,assignment" wizardActionSelection=true groupSelection="value,output" outputDefaultSelection="group" context="action")}} />
    </div>
  </div>
{{/if}}

{{#if this.routeTo}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.route_to.url"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.url}} @property="url" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash context="action" wizardFieldSelection=true userFieldSelection="key,value" groupSelection="key,value" categorySelection="key,value" userSelection="key,value")}} />
    </div>
  </div>
{{/if}}

{{#if this.watchCategories}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_categories.categories"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.categories}} @property="categories" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="key,value" wizardFieldSelection=true wizardActionSelection=true userFieldSelection="key,value" categorySelection="output" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_categories.mute_remainder"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.mute_remainder}} @property="mute_remainder" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash context="action" wizardFieldSelection=true userFieldSelection="key,value")}} />
    </div>
  </div>

  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_x.notification_level.label"}}</label>
    </div>

    <div class="setting-value">
      <ComboBox @value={{this.action.notification_level}} @content={{this.availableNotificationLevels}} @onChange={{(fn (mut this.action.notification_level))}} @options={{(hash isDisabled=this.action.custom_title_enabled none="admin.wizard.action.watch_x.select_a_notification_level")}} />
    </div>
  </div>

  <div class="setting full">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_x.wizard_user"}}</label>
    </div>

    <div class="setting-value">
      <Input @type="checkbox" @checked={{this.action.wizard_user}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_x.usernames"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.usernames}} @property="usernames" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash context="action" wizardFieldSelection=true userFieldSelection="key,value" userSelection="output")}} />
    </div>
  </div>
{{/if}}

{{#if this.watchTags}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_tags.tags"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.tags}} @property="tags" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="key,value" tagSelection="output" wizardFieldSelection=true wizardActionSelection=true userFieldSelection="key,value" context="action")}} />
    </div>
  </div>

  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_x.notification_level.label"}}</label>
    </div>

    <div class="setting-value">
      <ComboBox @value={{this.action.notification_level}} @content={{this.availableNotificationLevels}} @onChange={{(fn (mut this.action.notification_level))}} @options={{(hash isDisabled=this.action.custom_title_enabled none="admin.wizard.action.watch_x.select_a_notification_level")}} />
    </div>
  </div>

  <div class="setting full">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_x.wizard_user"}}</label>
    </div>

    <div class="setting-value">
      <Input @type="checkbox" @checked={{this.action.wizard_user}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.watch_x.usernames"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.usernames}} @property="usernames" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash context="action" wizardFieldSelection=true userFieldSelection="key,value" userSelection="output")}} />
    </div>
  </div>
{{/if}}

{{#if this.createGroup}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.name"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.name}} @property="name" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.full_name"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.full_name}} @property="full_name" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.title"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.title}} @property="title" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.bio_raw"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.bio_raw}} @property="bio_raw" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.owner_usernames"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.owner_usernames}} @property="owner_usernames" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true userSelection="output" context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.usernames"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.usernames}} @property="usernames" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true userSelection="output" context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.grant_trust_level"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.grant_trust_level}} @property="grant_trust_level" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.mentionable_level"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.mentionable_level}} @property="mentionable_level" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.messageable_level"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.messageable_level}} @property="messageable_level" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.visibility_level"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.visibility_level}} @property="visibility_level" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_group.members_visibility_level"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.members_visibility_level}} @property="members_visibility_level" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection=true context="action")}} />
    </div>
  </div>
{{/if}}

{{#if this.createCategory}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_category.name"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.name}} @property="name" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="key,value,output" wizardFieldSelection=true userFieldSelection="key,value" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_category.slug"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.slug}} @property="slug" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection="key,value" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_category.color"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.color}} @property="color" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection="key,value" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_category.text_color"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.text_color}} @property="text_color" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection=true wizardFieldSelection=true userFieldSelection="key,value" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_category.parent_category"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.parent_category_id}} @property="parent_category_id" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="key,value" wizardFieldSelection=true userFieldSelection="key,value" categorySelection="output" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.create_category.permissions"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.permissions}} @property="permissions" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash inputTypes="association" textSelection=true wizardFieldSelection=true wizardActionSelection="key" userFieldSelection=true groupSelection="key" context="action")}} />
    </div>
  </div>
{{/if}}

{{#if this.hasCustomFields}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.custom_fields.label"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.custom_fields}} @property="custom_fields" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash inputTypes="association" customFieldSelection="key" wizardFieldSelection="value" wizardActionSelection="value" userFieldSelection="value" keyPlaceholder="admin.wizard.action.custom_fields.key" context=this.customFieldsContext)}} />
    </div>
  </div>
{{/if}}

{{#if this.sendMessage}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.required"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.required}} @property="required" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="value" wizardFieldSelection=true userFieldSelection=true groupSelection=true context="action")}} />
    </div>
  </div>
{{/if}}

{{#if this.showPostAdvanced}}
  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.poster.label"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.poster}} @property="poster" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="key,value" wizardFieldSelection=true userSelection="output" outputDefaultSelection="user" userLimit="1" context="action")}} />
    </div>
  </div>

  <div class="setting full field-mapper-setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.guest_email.label"}}</label>
    </div>

    <div class="setting-value">
      <WizardMapper @inputs={{this.action.guest_email}} @property="guest_email" @onUpdate={{this.mappedFieldUpdated}} @options={{(hash textSelection="key,value" wizardFieldSelection=true outputPlaceholder="admin.wizard.action.guest_email.placeholder" context="action")}} />
    </div>
  </div>

  <div class="setting full">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.skip_redirect.label"}}</label>
    </div>

    <div class="setting-value">
      <Input @type="checkbox" @checked={{this.action.skip_redirect}} />

      <span>
        {{i18n "admin.wizard.action.skip_redirect.description" type="topic"}}
      </span>
    </div>
  </div>

  <div class="setting full">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.suppress_notifications.label"}}</label>
    </div>

    <div class="setting-value">
      <Input @type="checkbox" @checked={{this.action.suppress_notifications}} />

      <span>
        {{i18n "admin.wizard.action.suppress_notifications.description" type="topic"}}
      </span>
    </div>
  </div>
{{/if}}

{{#if this.routeTo}}
  <div class="setting">
    <div class="setting-label">
      <label>{{i18n "admin.wizard.action.route_to.code"}}</label>
    </div>

    <div class="setting-value">
      <Input @value={{this.action.code}} />
    </div>
  </div>
{{/if}}</template>}
