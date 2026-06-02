// Real onboarding wizard FIELDS (extracted from the production export).
// Used by onboarding-real-config-test.js, merged onto the generic serialized field shape.
export default [
  {
    "id": "step_1_field_1",
    "type": "checkbox",
    "required": true,
    "description": "I confirm I am not a current undergraduate student"
  },
  {
    "id": "step_1_field_8",
    "type": "checkbox",
    "required": true,
    "description": "I agree to the [Terms of Service](/tos), [Privacy Policy](/privacy), and [Community Guidelines](/guidelines)"
  },
  {
    "id": "step_1_field_2",
    "type": "textarea",
    "required": true,
    "label": "Role",
    "description": "Describe your role in computing education. For example: \"I'm a Teaching Professor who builds educational tools.\"",
    "min_length": "5",
    "max_length": "500",
    "char_counter": true
  },
  {
    "id": "step_1_field_7",
    "type": "text",
    "required": true,
    "label": "Institution",
    "description": "Your academic or professional institution",
    "validations": {
      "similar_topics": {}
    },
    "min_length": "2",
    "max_length": "200",
    "char_counter": true
  },
  {
    "id": "step_1_field_10",
    "type": "email",
    "required": true,
    "label": "Institutional Email",
    "description": "Please enter your official university email address. This does not need to be the same as the one you use to log in.",
    "allowed_domains": "edu|edu.au|edu.br|edu.cn|edu.co|edu.eg|edu.gh|edu.hk|edu.mx|edu.my|edu.ng|edu.pe|edu.ph|edu.pk|edu.pl|edu.sg|edu.tr|edu.tw|edu.vn|ac.ae|ac.at|ac.bd|ac.bw|ac.cn|ac.cr|ac.cy|ac.id|ac.il|ac.in|ac.ir|ac.jp|ac.ke|ac.kr|ac.lk|ac.ma|ac.nz|ac.pg|ac.rs|ac.rw|ac.ss|ac.th|ac.tz|ac.ug|ac.uk|ac.uz|ac.za|ac.zm|ac.zw|ca|de|fr|ch|nl|jo"
  },
  {
    "id": "step_1_field_9",
    "type": "text",
    "label": "Personal Pronouns",
    "validations": {
      "similar_topics": {}
    }
  },
  {
    "id": "step_1_field_4",
    "type": "url",
    "required": true,
    "label": "Website",
    "description": "Link to your academic or professional homepage"
  },
  {
    "id": "step_1_field_5",
    "type": "textarea",
    "label": "Engagement Goals",
    "description": "What you hope to get out of engaging with this community?",
    "max_length": "500",
    "char_counter": true
  },
  {
    "id": "step_1_field_6",
    "type": "textarea",
    "label": "Referral",
    "description": "How did you hear about us?",
    "max_length": "500",
    "char_counter": true
  }
];
