RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'wowr'

Rails::Initializer.run do |config|
  config.time_zone = 'Pacific Time (US & Canada)'
  config.gem "thoughtbot-clearance", 
    :lib     => 'clearance', 
    :source  => 'http://gems.github.com', 
    :version => '0.5.3'
#  config.gem "searchlogic"
  config.gem "httparty", :version => ">= 0.4.2"
  
  config.action_controller.session = {
    :session_key => '_guild_session',
    :secret      => '2bf36eeeb12568f4d17fff024e73df0927fdd9291b57339985026b1f075bec4f21519ad19922624d5232d591858a85d496708ea3d2117ca014a9cc627eaee20d'
  }
  
  DO_NOT_REPLY = "admin@wheee.org"
  HOST = "wheee.org"
  
  GUILD_NAME = "Rising Storm"
  REALM_NAME = "Lightbringer"
  API_CHARACTER_NAME = "Kemnon"
  WOWR_DEFAULTS = {
    :character_name => API_CHARACTER_NAME,
    :guild_name     => GUILD_NAME,
    :realm          => REALM_NAME,
    :caching        => false
  }
  MENU = {
#    'Forums' => ['forums', 'topics', 'posts'],
    'Raids' => ['raids'],
    'Loots' => ['loots'],
    'Toons' => ['toons'],
#    'Guild Bank' => ['guild_bank'],
#    'Calendar' => ['calendar'],
    'Achievements' => ['achievements']
  }
  PUBLIC_MENUS = ['Toons', 'Achievements']
  RANKS = ['Guild Master', 'Officer', 'Organizer', 'Raider', 'Trial', 'Alt', 'Member']
  RAIDER_RANKS = [0, 2, 3, 4]
end
