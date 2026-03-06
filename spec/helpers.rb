module Helpers
  def login
    visit "/"
    fill_in "login[email]", with: user.email
    click_button "Login"
    user.reload
    fill_in "login[code]", with: user.code_hash
    click_button "Verify Code"
  end

  def login_as(user)
    visit "/"
    fill_in "login[email]", with: user.email
    click_button "Login"
    user.reload
    fill_in "login[code]", with: user.code_hash
    click_button "Verify Code"
  end
end
