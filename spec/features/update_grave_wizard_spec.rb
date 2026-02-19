require "rails_helper"

feature "update grave wizard" do
  let(:publication) { create(:publication) }
  let(:image) { create(:image) }
  let(:publication_page) { create(:page, image: image, publication: publication) }
  let(:grave) { create(:grave, page: publication_page, publication: publication) }
  let(:skeleton) { create(:skeleton_figure, grave: grave) }
  let!(:site) { create(:site) }
  let!(:tag) { create(:tag) }
  let(:user) { create(:user) }

  before do
    allow_any_instance_of(AuthorizedController).to receive(:current_user).and_return(user)
  end

  describe "wizard navigation" do
    it "navigates through wizard steps" do
      visit grave_update_grave_path(grave, :set_grave_data)

      fill_in "grave[identifier]", with: "new_identifier"
      click_button "Next"

      select site.name, from: "grave_site_id"
      click_button "Next"

      check "grave_tag_ids_#{tag.id}"
      click_button "Next"

      visit grave_update_grave_path(grave, :show_contours)

      click_button "Next"

      fill_in "grave_percentage_scale", with: "100:1"
      click_button "Next"

      click_link "Next"

      click_button "Next"
    end
  end

  # describe "skeleton keypoints" do
  #   it "creates keypoints for skeleton" do
  #     visit grave_update_grave_path(grave, :set_skeleton_data)

  #     # Mock the analysis service
  #     allow_any_instance_of(AnalyzeSkeleton).to receive(:run).and_return([
  #       { "head" => { x: 10, y: 20 }, "spine" => { x: 30, y: 40 } }
  #     ])

  #     click_button "Analyze Skeleton"

  #     expect(page).to have_content("Keypoints created")
  #     expect(skeleton.key_points.count).to eq(2)
  #     expect(skeleton.key_points.find_by(label: "head").x).to eq(10)
  #     expect(skeleton.key_points.find_by(label: "spine").x).to eq(30)
  #   end
  # end

  describe "wizard completion" do
    context "when next grave exists" do
      let!(:next_grave) { create(:grave, id: grave.id + 1, publication: grave.publication, probability: 0.7, page: grave.page) }

      it "redirects to next grave" do
        visit grave_update_grave_path(grave, :set_skeleton_data)
        click_button "Next"
        expect(page).to have_current_path(grave_update_grave_path(next_grave, :set_grave_data))
      end
    end

    context "when no next grave exists" do
      it "redirects to next grave" do
        visit grave_update_grave_path(grave, :set_skeleton_data)
        click_button "Next"
        expect(page).to have_current_path(graves_path)
      end
    end

    context "when no next grave exists" do
      it "redirects to graves index" do
        visit grave_update_grave_path(grave, :set_skeleton_data)
        click_button "Next"
        expect(page).to have_current_path(graves_path)
      end
    end
  end
end
