require "rails_helper"

feature "sign in" do
  let!(:user) { create(:user) }

  it "logs in" do
    visit "/"
    expect(page).to have_current_path(login_path)

    fill_in "login[email]", with: user.email
    click_button "Login"
    expect(page).to have_current_path(login_path)

    user.reload
    fill_in "login[code]", with: user.code_hash
    click_button "Verify Code"
    expect(page).to have_current_path("/")

    expect(page).to have_css("a.nav-link", text: user.name)
  end

  it "logs in with invalid username" do
    visit "/"
    expect(page).to have_current_path(login_path)

    fill_in "login[email]", with: user.email + "does not exist"
    click_button "Login"
    expect(page).to have_current_path(login_path)

    expect(page).to have_css("div.alert", text: "Please enter a valid email address.")
  end

  it "logs in with invalid code" do
    visit "/"
    expect(page).to have_current_path(login_path)

    fill_in "login[email]", with: user.email
    click_button "Login"
    expect(page).to have_current_path(login_path)

    user.reload
    fill_in "login[code]", with: user.code_hash + "AAAA"
    click_button "Verify Code"
    expect(page).to have_current_path(login_path)

    expect(page).to have_css("div.alert", text: "The code you entered was not correct.")
  end

  it "logs out" do
    login

    click_link "Logout"

    expect(page).to have_current_path(login_path)
  end
end
