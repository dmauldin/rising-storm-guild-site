require 'test_helper'

class ToonsTest < ActionController::IntegrationTest
  test "displaying toon list with a toon with no professions" do
    toon = Factory(:toon)
    visit toons_url
    assert_contain toon.name
  end
end