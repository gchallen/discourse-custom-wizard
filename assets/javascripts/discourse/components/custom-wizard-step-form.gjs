import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default class CustomWizardStepForm extends Component {
  classNameBindings = [":wizard-step-form", "customStepClass"];

  @discourseComputed("step.id")
  customStepClass(stepId) {
    return `wizard-step-${stepId}`;
  }

  <template>{{yield}}</template>
}
