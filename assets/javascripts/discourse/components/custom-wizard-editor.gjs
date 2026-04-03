import htmlSafe from "discourse/helpers/html-safe";
import { on } from "@ember/modifier";
import toolbarPopupMenuOptions from "discourse/components/toolbar-popup-menu-options";
import { hash, fn } from "@ember/helper";
import icon from "discourse/helpers/d-icon";
import i18n from "discourse/helpers/i18n";
import conditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import { Textarea } from "@ember/component";
const CustomWizardEditor = <template><div class="d-editor-overlay hidden"></div>

<div class="d-editor-container">
  {{#if this.showPreview}}
    <div class="d-editor-preview-wrapper {{if this.forcePreview "force-preview"}}">
      <div class="d-editor-preview">
        {{htmlSafe this.preview}}
      </div>
    </div>
  {{else}}
    <div class="d-editor-textarea-wrapper">
      <div class="d-editor-button-bar">
        {{#each this.toolbar.groups as |group|}}
          {{#each group.buttons as |b|}}
            {{#if b.popupMenu}}
              {{toolbarPopupMenuOptions onPopupMenuAction=this.onPopupMenuAction onExpand=(fn b.action b) class=b.className content=this.popupMenuOptions options=(hash popupTitle=b.title icon=b.icon)}}
            {{else}}
              <div>{{b.icon}}</div>
              <button class="wizard-btn {{b.className}}" {{on "click" (fn b.action b)}} title={{b.title}} type="button">
                {{icon b.icon}}
                {{#if b.label}}
                  <span class="d-button-label">{{i18n b.label}}</span>
                {{/if}}
              </button>
            {{/if}}
          {{/each}}

          {{#unless group.lastGroup}}
            <div class="d-editor-spacer"></div>
          {{/unless}}
        {{/each}}
      </div>

      {{conditionalLoadingSpinner condition=this.loading}}
      <Textarea tabindex={{this.tabindex}} @value={{this.value}} class="d-editor-input" placeholder={{this.placeholder}} />
    </div>
  {{/if}}
</div></template>;
export default CustomWizardEditor;
