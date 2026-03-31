# frozen_string_literal: true

describe CustomWizard::UserController do
  fab!(:admin_user) { Fabricate(:admin) }
  fab!(:user)

  before { sign_in(admin_user) }

  describe "#set_redirect" do
    it "sets redirect_to_wizard on a user" do
      put "/admin/users/#{user.id}/wizards/set_redirect.json", params: { wizard_id: "onboarding" }
      expect(response.status).to eq(200)
      expect(user.reload.custom_fields["redirect_to_wizard"]).to eq("onboarding")
    end

    it "fails without a wizard_id" do
      put "/admin/users/#{user.id}/wizards/set_redirect.json", params: {}
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed["failed"]).to eq("FAILED")
    end

    it "fails for non-existent user" do
      put "/admin/users/999999/wizards/set_redirect.json", params: { wizard_id: "onboarding" }
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed["failed"]).to eq("FAILED")
    end

    it "requires admin" do
      sign_in(user)
      put "/admin/users/#{user.id}/wizards/set_redirect.json", params: { wizard_id: "onboarding" }
      expect(response.status).to be_in([403, 404])
    end
  end

  describe "#clear_redirect" do
    before do
      user.custom_fields["redirect_to_wizard"] = "onboarding"
      user.save_custom_fields(true)
    end

    it "clears redirect_to_wizard on a user" do
      put "/admin/users/#{user.id}/wizards/clear_redirect.json"
      expect(response.status).to eq(200)
      expect(user.reload.custom_fields["redirect_to_wizard"]).to be_nil
    end
  end
end
