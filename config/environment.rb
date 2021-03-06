RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

require 'rubygems'
require 'open-uri'
require 'hpricot'
# require 'wowr'

Rails::Initializer.run do |config|
  config.time_zone = 'Pacific Time (US & Canada)'
  config.gem 'javan-whenever',
    :lib => false,
    :source => 'http://gems.github.com'
  config.gem 'thoughtbot-clearance', 
    :lib     => 'clearance', 
    :source  => 'http://gems.github.com', 
    :version => '0.5.6'
  config.gem 'searchlogic', :version => '1.6.6'
  config.gem 'httparty', :version => '>= 0.4.2'
  # config.gem 'wowr',
  #   :lib => 'wowr',
  #   :source => 'http://gems.github.com',
  #   :version => '>= 0.5.3'
  # config.gem 'less', :version => '1.1.3'
  config.action_controller.session = {
    :session_key => '_guild_session',
    :secret      => '2bf36eeeb12568f4d17fff024e73df0927fdd9291b57339985026b1f075bec4f21519ad19922624d5232d591858a85d496708ea3d2117ca014a9cc627eaee20d'
  }
  
  DO_NOT_REPLY = 'admin@wheee.org'
  HOST = 'wheee.org'
  
  GUILD_NAME = 'The Coalition'
  REALM_NAME = 'Lightbringer'
  API_CHARACTER_NAME = 'Arianne'
  WOWR_DEFAULTS = {
    :character_name => API_CHARACTER_NAME,
    :guild_name     => GUILD_NAME,
    :realm          => REALM_NAME,
    :caching        => false
  }
  MENU = {
    'Forums' => ['forums', 'topics', 'posts'],
    'Raids' => ['raids'],
    'Loots' => ['loots'],
    'Toons' => ['toons'],
    # 'Guild Bank' => ['guild_bank'],
    # 'Calendar' => ['calendar'],
    'Achievements' => ['achievements']
  }
  PUBLIC_MENUS = ['Toons', 'Achievements']
  RANKS = ['Guild Master', "Xig's Alts", 'Officer', 'Raider', 'Old Raider', 'Trial', 'Member']
  RAIDER_RANKS = [1, 2, 3, 5]
  RAIDER_EXCLUSIONS = %w(Dreadbringer Azshardalon Bitten Nobis Diig Dig Theldraskien Briareos Sei)
end
