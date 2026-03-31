# frozen_string_literal: true

describe CustomWizard::UpdateValidator do
  fab!(:user)
  let(:template) { get_wizard_fixture("wizard") }
  let(:url_field) { get_wizard_fixture("field/url") }

  before do
    CustomWizard::Template.save(template, skip_jobs: true)
    @template = CustomWizard::Template.find("super_mega_fun_wizard")
  end

  def perform_validation(step_id, submission)
    wizard = CustomWizard::Builder.new(@template[:id], user).build
    updater = wizard.create_updater(step_id, submission)
    updater.validate
    updater
  end

  it "applies min length to text type fields" do
    min_length = 3

    @template[:steps][0][:fields][0][:min_length] = min_length
    @template[:steps][0][:fields][1][:min_length] = min_length

    CustomWizard::Template.save(@template)

    updater = perform_validation("step_1", step_1_field_1: "Te")
    expect(updater.errors.messages[:step_1_field_1].first).to eq(
      I18n.t("wizard.field.too_short", label: "Text", min: min_length),
    )

    updater = perform_validation("step_1", step_1_field_2: "Te")
    expect(updater.errors.messages[:step_1_field_2].first).to eq(
      I18n.t("wizard.field.too_short", label: "Textarea", min: min_length),
    )
  end

  it "prevents submission if the length is over the max length" do
    max_length = 100

    @template[:steps][0][:fields][0][:max_length] = max_length
    @template[:steps][0][:fields][1][:max_length] = max_length

    CustomWizard::Template.save(@template)
    long_string =
      "Our Competitive Capability solution offers platforms a suite of wholesale offerings. In the future, will you be able to effectively revolutionize synergies in your business? In the emerging market space, industry is ethically investing its mission critical executive searches. Key players will take ownership of their capabilities by iteratively right-sizing world-class visibilities. "
    updater = perform_validation("step_1", step_1_field_1: long_string)
    expect(updater.errors.messages[:step_1_field_1].first).to eq(
      I18n.t("wizard.field.too_long", label: "Text", max: max_length),
    )

    updater = perform_validation("step_1", step_1_field_2: long_string)
    expect(updater.errors.messages[:step_1_field_2].first).to eq(
      I18n.t("wizard.field.too_long", label: "Textarea", max: max_length),
    )
  end

  it "allows submission if the length is under or equal to the max length" do
    max_length = 100

    @template[:steps][0][:fields][0][:max_length] = max_length
    @template[:steps][0][:fields][1][:max_length] = max_length

    CustomWizard::Template.save(@template)
    hundred_chars_string =
      "This is a line, exactly hundred characters long and not more even a single character more than that."
    updater = perform_validation("step_1", step_1_field_1: hundred_chars_string)
    expect(updater.errors.messages[:step_1_field_1].first).to eq(nil)

    updater = perform_validation("step_1", step_1_field_2: hundred_chars_string)
    expect(updater.errors.messages[:step_1_field_2].first).to eq(nil)
  end

  it "applies min length only if the input is non-empty" do
    min_length = 3

    @template[:steps][0][:fields][0][:min_length] = min_length

    CustomWizard::Template.save(@template)

    updater = perform_validation("step_1", step_1_field_1: "")
    expect(updater.errors.messages[:step_1_field_1].first).to eq(nil)
  end

  it "applies max length only if the input is non-empty" do
    max_length = 100

    @template[:steps][0][:fields][0][:max_length] = max_length

    CustomWizard::Template.save(@template)
    updater = perform_validation("step_1", step_1_field_1: "")
    expect(updater.errors.messages[:step_1_field_1].first).to eq(nil)
  end

  it "standardises boolean entries" do
    updater = perform_validation("step_2", step_2_field_5: "false")
    expect(updater.submission["step_2_field_5"]).to eq(false)
  end

  it "requires required fields" do
    @template[:steps][0][:fields][1][:required] = true
    CustomWizard::Template.save(@template)

    updater = perform_validation("step_1", step_1_field_2: nil)
    expect(updater.errors.messages[:step_1_field_2].first).to eq(
      I18n.t("wizard.field.required", label: "Textarea"),
    )
  end

  context "advanced fields" do
    it "validates url fields" do
      updater = perform_validation("step_2", step_2_field_6: "https://discourse.com")
      expect(updater.errors.messages[:step_2_field_6].first).to eq(nil)
    end

    it "does not validate url fields with non-url inputs" do
      template[:steps][0][:fields] << url_field
      CustomWizard::Template.save(template)
      updater = perform_validation("step_1", step_2_field_6: "discourse")
      expect(updater.errors.messages[:step_2_field_6].first).to eq(
        I18n.t("wizard.field.not_url", label: "Url"),
      )
    end

    it "validates empty url fields" do
      updater = perform_validation("step_2", step_2_field_6: "")
      expect(updater.errors.messages[:step_2_field_6].first).to eq(nil)
    end
  end

  context "email fields" do
    let(:email_field) { get_wizard_fixture("field/email") }

    before do
      template[:steps][0][:fields] << email_field
      CustomWizard::Template.save(template)
    end

    it "validates email fields with allowed academic domains" do
      updater = perform_validation("step_1", step_1_field_email: "user@university.edu")
      expect(updater.errors.messages[:step_1_field_email].first).to eq(nil)
    end

    it "validates email fields with subdomains of allowed domains" do
      updater = perform_validation("step_1", step_1_field_email: "user@cs.university.edu")
      expect(updater.errors.messages[:step_1_field_email].first).to eq(nil)
    end

    it "validates email fields with ac.uk domains" do
      updater = perform_validation("step_1", step_1_field_email: "user@oxford.ac.uk")
      expect(updater.errors.messages[:step_1_field_email].first).to eq(nil)
    end

    it "rejects email fields with non-allowed domains" do
      updater = perform_validation("step_1", step_1_field_email: "user@gmail.com")
      expect(updater.errors.messages[:step_1_field_email].first).to eq(
        I18n.t("wizard.field.invalid_email_domain", label: "Email", default: "%{label}: Email address is not from an allowed domain."),
      )
    end

    it "rejects email fields with similar but non-matching domains" do
      updater = perform_validation("step_1", step_1_field_email: "user@notedu.com")
      expect(updater.errors.messages[:step_1_field_email].first).to eq(
        I18n.t("wizard.field.invalid_email_domain", label: "Email", default: "%{label}: Email address is not from an allowed domain."),
      )
    end

    it "allows empty email fields when not required" do
      updater = perform_validation("step_1", step_1_field_email: "")
      expect(updater.errors.messages[:step_1_field_email].first).to eq(nil)
    end

    it "requires email fields when marked required" do
      email_field[:required] = true
      template[:steps][0][:fields] = template[:steps][0][:fields].reject { |f| f[:id] == "step_1_field_email" || f["id"] == "step_1_field_email" }
      template[:steps][0][:fields] << email_field
      CustomWizard::Template.save(template)

      updater = perform_validation("step_1", step_1_field_email: nil)
      expect(updater.errors.messages[:step_1_field_email].first).to eq(
        I18n.t("wizard.field.required", label: "Email"),
      )
    end

    it "accepts any email when allowed_domains is not set" do
      email_field.delete("allowed_domains")
      template[:steps][0][:fields] = template[:steps][0][:fields].reject { |f| f[:id] == "step_1_field_email" || f["id"] == "step_1_field_email" }
      template[:steps][0][:fields] << email_field
      CustomWizard::Template.save(template)

      updater = perform_validation("step_1", step_1_field_email: "user@gmail.com")
      expect(updater.errors.messages[:step_1_field_email].first).to eq(nil)
    end

    it "applies min_length to email fields" do
      email_field[:min_length] = 10
      template[:steps][0][:fields] = template[:steps][0][:fields].reject { |f| f[:id] == "step_1_field_email" || f["id"] == "step_1_field_email" }
      template[:steps][0][:fields] << email_field
      CustomWizard::Template.save(template)

      updater = perform_validation("step_1", step_1_field_email: "a@b.edu")
      expect(updater.errors.messages[:step_1_field_email].first).to eq(
        I18n.t("wizard.field.too_short", label: "Email", min: 10),
      )
    end
  end

  it "validates date fields" do
    @template[:steps][1][:fields][0][:format] = "DD-MM-YYYY"
    CustomWizard::Template.save(@template)

    updater = perform_validation("step_2", step_2_field_1: "13-11-2021")
    expect(updater.errors.messages[:step_2_field_1].first).to eq(nil)
  end

  it 'doesn\'t validate date field if the format is not respected' do
    @template[:steps][1][:fields][0][:format] = "MM-DD-YYYY"
    CustomWizard::Template.save(@template)

    updater = perform_validation("step_2", step_2_field_1: "13-11-2021")
    expect(updater.errors.messages[:step_2_field_1].first).to eq(
      I18n.t("wizard.field.invalid_date"),
    )
  end

  it "validates date time fields" do
    @template[:steps][1][:fields][2][:format] = "DD-MM-YYYY HH:mm:ss"
    CustomWizard::Template.save(@template)

    updater = perform_validation("step_2", step_2_field_3: "13-11-2021 09:15:00")
    expect(updater.errors.messages[:step_2_field_3].first).to eq(nil)
  end

  it 'doesn\'t validate date time field if the format is not respected' do
    @template[:steps][1][:fields][2][:format] = "MM-DD-YYYY HH:mm:ss"
    CustomWizard::Template.save(@template)

    updater = perform_validation("step_2", step_2_field_3: "13-11-2021 09:15")
    expect(updater.errors.messages[:step_2_field_3].first).to eq(
      I18n.t("wizard.field.invalid_date"),
    )
  end
end
