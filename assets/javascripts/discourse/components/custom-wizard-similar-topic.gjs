import htmlSafe from "discourse/helpers/html-safe";
import RelativeDate from "discourse/components/relative-date";
const CustomWizardSimilarTopic = <template><a href={{this.topic.url}} target="_blank" rel="noopener noreferrer">
  <span class="title">{{htmlSafe this.topic.fancy_title}}</span>
  <div class="blurb"><RelativeDate @date={{@topic.created_at}} />
    -
    {{htmlSafe this.topic.blurb}}</div>
</a></template>;
export default CustomWizardSimilarTopic;
