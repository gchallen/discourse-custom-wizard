# frozen_string_literal: true

describe CustomWizard::WizardController do
  fab!(:user) do
    Fabricate(:user, username: "angus", email: "angus@email.com", trust_level: TrustLevel[3])
  end
  let(:wizard_template) { get_wizard_fixture("wizard") }
  let(:permitted_json) { get_wizard_fixture("wizard/permitted") }

  before do
    CustomWizard::Template.save(wizard_template, skip_jobs: true)
    @template = CustomWizard::Template.find("super_mega_fun_wizard")
  end

  context "plugin disabled" do
    before { SiteSetting.custom_wizard_enabled = false }

    it "redirects to root" do
      get "/w/super-mega-fun-wizard", xhr: true
      expect(response).to redirect_to("/")
    end
  end

  it "returns wizard" do
    get "/w/super-mega-fun-wizard.json"
    expect(response.parsed_body["id"]).to eq("super_mega_fun_wizard")
  end

  it "returns missing message if no wizard exists" do
    get "/w/super-mega-fun-wizards.json"
    expect(response.parsed_body["error"]).to eq("We couldn't find a wizard at that address.")
  end

  context "stuck onboarding user (kksgandhi scenario)" do
    before do
      # Mirror the production onboarding wizard flags
      @template["after_signup"] = true
      @template["required"] = true
      @template["multiple_submissions"] = true
      @template["restart_on_revisit"] = true
      CustomWizard::Template.save(@template, skip_jobs: true)

      sign_in(user)
      # User is flagged for forced redirect (never cleared because never completed)
      user.custom_fields["redirect_to_wizard"] = "super_mega_fun_wizard"
      user.save_custom_fields(true)

      # An incomplete submission holding only a redirect_to, no submitted_at
      wizard = CustomWizard::Wizard.create("super_mega_fun_wizard", user)
      sub = wizard.current_submission
      sub.redirect_to = "/t/redesigning-cs1/234/4"
      sub.save
    end

    it "still renders the wizard rather than 'couldn't find a wizard'" do
      get "/w/super-mega-fun-wizard.json"
      expect(response.status).to eq(200)
      expect(response.parsed_body["error"]).to be_nil
      expect(response.parsed_body["id"]).to eq("super_mega_fun_wizard")
    end
  end

  context "with user" do
    before { sign_in(user) }

    context "when user skips" do
      it "skips a wizard if user is allowed to skip" do
        put "/w/super-mega-fun-wizard/skip.json"
        expect(response.status).to eq(200)
      end

      it "lets user skip if user cant access wizard" do
        enable_subscription("standard")
        @template["permitted"] = permitted_json["permitted"]
        CustomWizard::Template.save(@template, skip_jobs: true)
        put "/w/super-mega-fun-wizard/skip.json"
        expect(response.status).to eq(200)
      end

      it "returns a no skip message if user is not allowed to skip" do
        enable_subscription("standard")
        @template["required"] = "true"
        CustomWizard::Template.save(@template)
        put "/w/super-mega-fun-wizard/skip.json"
        expect(response.parsed_body["error"]).to eq("Wizard can't be skipped")
      end

      it "skip response contains a redirect_to if in users submissions" do
        @wizard = CustomWizard::Wizard.create(@template["id"], user)
        CustomWizard::Submission.new(@wizard, redirect_to: "/t/2").save
        put "/w/super-mega-fun-wizard/skip.json"
        expect(response.parsed_body["redirect_to"]).to eq("/t/2")
      end

      it "deletes the users redirect_to_wizard if present" do
        user.custom_fields["redirect_to_wizard"] = @template["id"]
        user.save_custom_fields(true)
        @wizard = CustomWizard::Wizard.create(@template["id"], user)
        put "/w/super-mega-fun-wizard/skip.json"
        expect(response.status).to eq(200)
        expect(user.reload.redirect_to_wizard).to eq(nil)
      end

      it "deletes the submission if user has filled up some data" do
        @wizard = CustomWizard::Wizard.create(@template["id"], user)
        CustomWizard::Submission.new(@wizard, step_1_field_1: "Hello World").save
        current_submission = @wizard.current_submission
        put "/w/super-mega-fun-wizard/skip.json"
        submissions = CustomWizard::Submission.list(@wizard).submissions

        expect(submissions.any? { |submission| submission.id == current_submission.id }).to eq(
          false,
        )
      end

      it "starts from the first step if user visits after skipping the wizard" do
        put "/w/super-mega-fun-wizard/steps/step_1.json",
            params: {
              fields: {
                step_1_field_1: "Text input",
              },
            }
        put "/w/super-mega-fun-wizard/skip.json"
        get "/w/super-mega-fun-wizard.json"

        expect(response.parsed_body["start"]).to eq("step_1")
      end
    end
  end
end
