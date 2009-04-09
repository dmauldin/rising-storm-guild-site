require 'test_helper'

class ToonsTest < ActionController::IntegrationTest
  context "viewing the toon list with a toon with no professions" do
    setup do
      @toon = Factory(:toon)
      @normal_glory = Factory(:achievement, :id => 2137)
      @heroic_glory = Factory(:achievement, :id => 2138)
      @normal_glory.criterias << Factory(:achievement)
      @heroic_glory.criterias << Factory(:achievement)
    end
    
    should "have 1 toon in the list" do
      assert Toon.count == 1
    end
    
    should "show the toon in the list" do
      visit toons_url
      assert_contain @toon.name
    end
  end
end