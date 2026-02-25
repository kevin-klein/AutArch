# spec/features/team_management_spec.rb
require "rails_helper"

RSpec.feature "Team management", type: :feature do
  let!(:admin) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:publication) { create(:publication, user: admin) }

  scenario "Create a team" do
    login_as(admin)

    visit new_team_path
    fill_in "team_name", with: "Ruby Squad"
    fill_in "team_description", with: "All Ruby lovers"
    click_button "Create Team"
    expect(page).to have_content("Team was successfully created.")
    expect(page).to have_content("Ruby Squad")
  end

  scenario "Add a user to a team" do
    login_as(admin)

    team = create(:team)
    team.user_teams.create!(user: admin)
    visit team_path(team)

    click_link "Add User"
    select other_user.email, from: "Select User"
    click_button "Add User"
    expect(page).to have_content(other_user.email)
  end

  scenario "Add a publication to a team" do
    login_as(admin)

    team = create(:team)
    team.user_teams.create!(user: admin)

    visit team_path(team)
    click_link "Add Publication"
    select publication.title, from: "Select Publication"
    click_button "Add Publication"
    expect(page).to have_content(publication.title)
  end
end
