import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings(":wizard-step-form", "customStepClass")
export default class CustomWizardStepForm extends Component {

  @discourseComputed("step.id")
  customStepClass(stepId) {
    return `wizard-step-${stepId}`;
  }

  <template>{{yield}}</template>
}
