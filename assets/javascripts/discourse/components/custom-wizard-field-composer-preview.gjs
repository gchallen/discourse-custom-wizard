import Component from "@ember/component";
import { schedule } from "@ember/runloop";
import $ from "jquery";
import { resolveAllShortUrls } from "pretty-text/upload-short-url";
import { ajax } from "discourse/lib/ajax";
import { loadOneboxes } from "discourse/lib/load-oneboxes";
import discourseDebounce from "discourse-common/lib/debounce";
import { on } from "discourse-common/utils/decorators";
import htmlSafe from "discourse/helpers/html-safe";

export default class extends Component {
  @on("init")
  updatePreview() {
    if (this.isDestroyed) {
      return;
    }

    schedule("afterRender", () => {
      if (this._state !== "inDOM" || !this.element) {
        return;
      }

      const $preview = $(this.element);

      if ($preview.length === 0) {
        return;
      }

      this.previewUpdated($preview);
    });
  }

  previewUpdated($preview) {
    // Paint oneboxes
    const paintFunc = () => {
      loadOneboxes(
        $preview[0],
        ajax,
        null,
        null,
        this.siteSettings.max_oneboxes_per_post,
        true // refresh on every load
      );
    };

    discourseDebounce(this, paintFunc, 450);

    // Short upload urls need resolution
    resolveAllShortUrls(ajax, this.siteSettings, $preview[0]);
  }
<template><div class="wizard-composer-preview d-editor-preview-wrapper">
  <div class="d-editor-preview">
    {{htmlSafe this.field.preview_template}}
  </div>
</div></template>}
