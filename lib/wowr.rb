# 
# Wowr - Ruby library for the World of Warcraft Armory
# http://wowr.rubyforge.org/
# Written by Ben Humphreys
# http://benhumphreys.co.uk/
# 
# Author:: Ben Humphreys
# May not be used for commercial applications
# 

begin
	require 'hpricot' # version 0.6
rescue LoadError
	require 'rubygems'
	require 'hpricot'
end
require 'net/http'
require 'net/https'
require 'cgi'
require 'fileutils'

$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'wowr/exceptions.rb'
require 'wowr/extensions.rb'

require 'wowr/character.rb'
require 'wowr/guild.rb'
require 'wowr/item.rb'
require 'wowr/arena_team.rb'
require 'wowr/dungeon.rb'
require 'wowr/guild_bank.rb'

module Wowr
	class API
		VERSION = '0.4.1'
		
		@@armory_base_url = 'wowarmory.com/'
		
		@@search_url = 'search.xml'
		
		@@character_sheet_url				= 'character-sheet.xml'
		@@character_talents_url			= 'character-talents.xml'
		@@character_skills_url			= 'character-skills.xml'
		@@character_reputation_url	= 'character-reputation.xml'
		
		@@guild_info_url		= 'guild-info.xml'
		
		@@item_info_url			= 'item-info.xml'
		@@item_tooltip_url	= 'item-tooltip.xml'
		
		@@arena_team_url = 'team-info.xml'
		
		@@guild_bank_contents_url = 'vault/guild-bank-contents.xml'
		@@guild_bank_log_url      = 'vault/guild-bank-log.xml'
		
		@@login_url = 'login.xml'

		@@dungeons_url = 'data/dungeons.xml'                	
		@@dungeons_strings_url = 'data/dungeonStrings.xml'

		@@max_connection_tries = 10
		
		@@cache_directory_path = 'cache/'
		
		@@user_agent = 'Mozilla/5.0 Gecko/20070219 Firefox/2.0.0.2'
		
		@@default_cache_timeout = (7*24*60*60)
		@@failed_cache_timeout = (60*60*24)
		@@cache_failed_requests = true # cache requests that resulted in an error from the armory
		
		cattr_accessor :armory_base_url, :search_url,
									 :character_sheet_url, :character_talents_url, :character_skills_url, :character_reputation_url,
									 :guild_info_url,
									 :item_info_url, :item_tooltip_url,
									 :arena_team_url,
									 :guild_bank_contents_url, :guild_bank_log_url,
									 :login_url,
									 :dungeons_url, :dungeons_strings_url,
									 :max_connection_tries,
									 :cache_directory_path,
									 :default_cache_timeout, :failed_cache_timeout, :cache_failed_requests
		
		@@search_types = {
			:item => 'items',
			:character => 'characters',
			:guild => 'guilds',
			:arena_team => 'arenateams'
		}
		
		@@arena_team_sizes = [2, 3, 5]
		
		attr_accessor :character_name, :guild_name, :realm, :locale, :lang, :caching, :cache_timeout, :debug
		
		
		# Constructor
		# Accepts an optional hash of parameters to create defaults for all API requests
		# * options (Hash) - Hash used to set default values for all API requests
		def initialize(options = {})
			@character_name = options[:character_name]
			@guild_name			= options[:guild_name]
			@realm					= options[:realm]
			@locale					= options[:locale] || 'us'
			@lang						= options[:lang].nil? ? 'default' : options[:lang]
			@caching				= options[:caching].nil? ? true : options[:caching]
			@cache_timeout	= options[:cache_timeout] || @@default_cache_timeout
			@debug					= options[:debug] || false
		end
		
		
		# General-purpose search
		# All specific searches are wrappers around this method. Best to use those instead.
		# Returns an array of results of the type requested (Wowr::Classes::SearchCharacter etc.) or an empty array.
		# Searches across all realms.
		# Caching is disabled for searching.
		# * string (String) Search string
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def search(string, options = {})
			if (string.is_a?(Hash))
				options = string
			else
				options.merge!(:search => string)
			end
			
			options = merge_defaults(options)
			
			if options[:search].nil? || options[:search].empty?
				raise Wowr::Exceptions::NoSearchString.new
			end
			
			if !@@search_types.has_value?(options[:type])
				raise Wowr::Exceptions::InvalidSearchType.new(options[:type])
			end
			
			options.merge!(:caching => false)
			options.delete(:realm) # all searches are across realms
						
			xml = get_xml(@@search_url, options)
			
			results = []
						
			if (xml) && (xml%'armorySearch') && (xml%'armorySearch'%'searchResults')
				case options[:type]
					
					when @@search_types[:item]
						(xml%'armorySearch'%'searchResults'%'items'/:item).each do |item|
							results << Wowr::Classes::SearchItem.new(item)
						end
					
					when @@search_types[:character]
						(xml%'armorySearch'%'searchResults'%'characters'/:character).each do |char|
							results << Wowr::Classes::SearchCharacter.new(char, self)
						end
					
					when @@search_types[:guild]
						(xml%'armorySearch'%'searchResults'%'guilds'/:guild).each do |guild|
							results << Wowr::Classes::SearchGuild.new(guild)
						end
					
					when @@search_types[:arena_team]
						(xml%'armorySearch'%'searchResults'%'arenaTeams'/:arenaTeam).each do |team|
							results << Wowr::Classes::SearchArenaTeam.new(team)
						end
				end
			end
			
			return results
		end
		
		
		# Characters
		# Returns an array of results of Wowr::Classes::SearchCharacter or an empty array.
		# Searches across all realms.
		# Caching is disabled for searching.
		# Parameters
		# * name (String) Name of the character to search for
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def search_characters(name, options = {})
			if (name.is_a?(Hash))
				options = name
			else
				options.merge!(:search => name)
			end
			
			options.merge!(:type => @@search_types[:character])
			return search(options)
		end
		
		
		# Get the full details of a character.
		# Requires realm.
		# * name (String) Name of the character to get, defaults to that specified in constructor
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_character(name = @character_name, options = {})
			if (name.is_a?(Hash))
				options = name
			else
				options.merge!(:character_name => name)
				
				# TODO check
				options = {:character_name => @character_name}.merge(options) if (!@character_name.nil?)
			end
			
			options = merge_defaults(options)
			
			if options[:character_name].nil? || options[:chracter_name] == ""
				raise Wowr::Exceptions::CharacterNameNotSet.new
			elsif options[:realm].nil? || options[:realm] == ""
				raise Wowr::Exceptions::RealmNotSet.new
			end
			
			character_sheet = get_xml(@@character_sheet_url, options)
			character_skills = get_xml(@@character_skills_url, options)
			character_reputation = get_xml(@@character_reputation_url, options)
			
			# FIXME
			if true
				return Wowr::Classes::FullCharacter.new(character_sheet,
																								character_skills,
																								character_reputation,
																								self)
			else
				raise Wowr::Excceptions::CharacterNotFound.new(options[:character_name])
			end
		end
		
		
		# DEPRECATED
		# See get_character
		def get_character_sheet(name = @character_name, options = {})
			return get_character(name, options)
		end

		# TODO
		# def get_character_skills
		# 	
		# end
		# 
		# def get_character_reputation
		# 	
		# end
		
		
		# Find all guilds with the given string, return array of Wowr::Classes::SearchGuild.
		# Searches across all realms.
		# Caching is disabled for searching.
		# * name (String) Name of the guild to search for
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def search_guilds(name, options = {})
			if (name.is_a?(Hash))
				options = name
			else
				options.merge!(:search => name)
			end
			options.delete(:realm)
			
			options.merge!(:type => @@search_types[:guild])
			return search(options)
		end
		
		
		# Get the guild details.
		# Guild name is optional, assuming it's set in the api constructor.
		# Requires realm.
		# * name (String) Name of the guild to retrieve, defaults to that specified in constructor
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_guild(name = @guild_name, options = {})
			if (name.is_a?(Hash))
				options = name
			else
				options.merge!(:guild_name => name)
			end
			
			options = merge_defaults(options)
			
			if options[:guild_name].nil? || options[:guild_name] == ""
				raise Wowr::Exceptions::GuildNameNotSet.new
			elsif options[:realm].nil? || options[:realm].empty?
				raise Wowr::Exceptions::RealmNotSet.new
			end
			
			xml = get_xml(@@guild_info_url, options)
			
			if (xml%'guildKey') && !(xml%'guildInfo').children.empty?
				return Wowr::Classes::FullGuild.new(xml)
			else
				raise Wowr::Exceptions::GuildNotFound.new(options[:guild_name])
			end
		end
		
		
		# Search for items with the specified name.
		# Returns an array of Wowr::Classes::SearchItem.
		# Searches across all realms.
		# Caching is disabled for searching.
		# * name (String) Name of the item
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def search_items(name, options = {})
			if (name.is_a?(Hash))
				options = name
			else
				options.merge!(:search => name)
			end
			
			options.merge!(:type => @@search_types[:item])
			return search(options)
		end
		
		
		# Get the full item details (Wowr::Classes::FullItem) with the given id.
		# Composite of Wowr::Classes::ItemInfo and Wowr::Classes::ItemTooltip data.
		# Item requests are identical across realms.
		# * id (Fixnum) ID of the item
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_item(id, options = {})
			if (id.is_a?(Hash))
				options = id
			else
				options.merge!(:item_id => id)
			end
			
			options = merge_defaults(options)
			options.delete(:realm)
			
			info = get_xml(@@item_info_url, options)
			tooltip = get_xml(@@item_tooltip_url, options)
			
			if (info%'itemInfo'%'item') && !tooltip.nil?
				return Wowr::Classes::FullItem.new(info%'itemInfo'%'item', tooltip%'itemTooltip', self)
			else
				raise Wowr::Exceptions::ItemNotFound.new(options[:item_id])
			end
		end
		
		
		# Get the basic item information Wowr::Classes::ItemInfo.
		# Item requests are identical across realms.
		# * id (Fixnum) ID of the item
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_item_info(id, options = {})
			if (id.is_a?(Hash))
				options = id
			else
				options.merge!(:item_id => id)
			end
			
			options = merge_defaults(options)
			options.delete(:realm)
			
			xml = get_xml(@@item_info_url, options)
			
			if (xml%'itemInfo'%'item')
				return Wowr::Classes::ItemInfo.new(xml%'itemInfo'%'item', self)
			else
				raise Wowr::Exceptions::ItemNotFound.new(options[:item_id])
			end
		end
		
		
		# Get full item details including stats Wowr::Classes::ItemTooltip.
		# Item requests are identical across realms.
		# * id (Fixnum) ID of the item
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_item_tooltip(id, options = {})
			if (id.is_a?(Hash))
				options = id
			else
				options.merge!(:item_id => id)
			end
			
			options = merge_defaults(options)
			options.delete(:realm)
			
			xml = get_xml(@@item_tooltip_url, options)
			
			if !xml.nil?
				return Wowr::Classes::ItemTooltip.new(xml%'itemTooltip')
			else
				raise Wowr::Exceptions::ItemNotFound.new(options[:item_id])
			end
		end
		
		
		# Search for arena teams with the given name of any size.
		# Returns an array of Wowr::Classes::SearchArenaTeam
		# Searches across all realms.
		# Caching is disabled for searching.
		# * name (String) Name of the arena team to seach for
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def search_arena_teams(name, options = {})
			if (name.is_a?(Hash))
				options = name
			else
				options.merge!(:search => name)
			end
			
			options.merge!(:type => @@search_types[:arena_team])
			return search(options)
		end
		
		
		# Get the arena team of the given name and size, on the specified realm.
		# Returns Wowr::Classes::FullArenaTeam
		# Requires realm.
		# * name (String) Team arena name
		# * size (Fixnum) Must be 2, 3 or 5
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_arena_team(name, size = nil, options = {})
			if name.is_a?(Hash)
				options = name
			elsif size.is_a?(Hash)
				options = size
				options.merge!(:team_name => name)
			else
				options.merge!(:team_name => name, :team_size => size)
			end
			
			options = merge_defaults(options)
						
			if options[:team_name].nil? || options[:team_name].empty?
				raise Wowr::Exceptions::ArenaTeamNameNotSet.new
			end
			
			if options[:realm].nil? || options[:realm].empty?
				raise Wowr::Exceptions::RealmNotSet.new
			end
			
			if !@@arena_team_sizes.include?(options[:team_size])
				raise Wowr::Exceptions::InvalidArenaTeamSize.new("Arena teams size must be: #{@@arena_team_sizes.inspect}")
			end
			
			xml = get_xml(@@arena_team_url, options)
			
			if !(xml%'arenaTeam').children.empty?
				return Wowr::Classes::ArenaTeam.new(xml%'arenaTeam')
			else
				raise Wowr::Exceptions::ArenaTeamNotFound.new(options[:team_name])
			end
		end
		
		
		# Get the current items within the guild bank.
		# Note that the bags and items the user can see is dependent on their privileges.
		# Requires realm.
		# * cookie (String) Cookie data returned by the login function.
		# * guild_name (String) Guild name
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_guild_bank_contents(cookie, guild_name = @guild_name, options = {})
			if (cookie.is_a?(Hash))
				options = cookie
			elsif (guild_name.is_a?(Hash))
				options = guild_name
				options.merge!(:cookie => cookie)
				options.merge!(:guild_name => @guild_name)
			else
				options.merge!(:cookie => cookie)
				options.merge!(:guild_name => guild_name)
			end			
			options = merge_defaults(options)
			
			if options[:cookie].nil? || options[:cookie] == ""
				raise Wowr::Exceptions::CookieNotSet.new
			elsif options[:guild_name].nil? || options[:guild_name] == ""
				raise Wowr::Exceptions::GuildNameNotSet.new
			elsif options[:realm].nil? || options[:realm] == ""
				raise Wowr::Exceptions::RealmNotSet.new
			end
			
			options.merge!(:secure => true)
			
			xml = get_xml(@@guild_bank_contents_url, options)
			
			if !(xml%'guildBank').children.empty?
				return Wowr::Classes::GuildBankContents.new(xml, self)
			else
				raise Wowr::Exceptions::GuildBankNotFound.new(options[:guild_name])
			end
		end
		
		
		# Get a particular page of the guild bank transaction log.
		# Each page contains up to 1000 transactions, other pages can be specified using :group in the options hash.
		# Note that data returned is specific to the logged in user's privileges.
		# Requires realm.
		# * cookie (String) Cookie data returned by the login function
		# * guild_name (String) Guild name
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_guild_bank_log(cookie, name = @guild_name, options = {})
			if (cookie.is_a?(Hash))
				options = cookie
			elsif (name.is_a?(Hash))
				options = name
				options.merge!(:cookie => cookie)
				options.merge!(:guild_name => @guild_name)
			else
				options.merge!(:cookie => cookie)
				options.merge!(:guild_name => name)
			end
			
			options = merge_defaults(options)
			
			if options[:cookie].nil? || options[:cookie] == ""
				raise Wowr::Exceptions::CookieNotSet.new
			elsif options[:guild_name].nil? || options[:guild_name] == ""
				raise Wowr::Exceptions::GuildNameNotSet.new
			elsif options[:realm].nil? || options[:realm] == ""
				raise Wowr::Exceptions::RealmNotSet.new
			end
			
			options.merge!(:secure => true)
			
			xml = get_xml(@@guild_bank_log_url, options)
			
			if !(xml%'guildBank').children.empty?
				return Wowr::Classes::GuildBankLog.new(xml, self)
			else
				raise Wowr::Exceptions::GuildBankNotFound.new(options[:guild_name])
			end
		end
		
		# Get complete list of dungeons.
		# WARNING: This gets two 6k xml files so it's not that fast
		# Takes 0.2s with cache, 2s without
		# New approach: Instead of passing the XML around and performing multiple
		# search lookups to find the elements, run through each XML file once
		# adding data to classes as they appear using hash lookup.
		# Went from 14s to 2s :)
		# * options (Hash) Optional hash of arguments identical to those used in the API constructor (realm, debug, cache etc.)
		def get_dungeons(options = {})
			options = merge_defaults(options)
			
			# dungeon_strings contains names for ids
			dungeon_xml = get_xml(@@dungeons_url, options)%'dungeons'
			
			dungeon_strings_xml = get_xml(@@dungeons_strings_url, options)
			
			results = {}
			
			# TODO: Pass the correct part of dungeon_strings_xml to each dungeon?
			if dungeon_xml && !dungeon_xml.children.empty?
				(dungeon_xml/:dungeon).each do |elem|
					dungeon = Wowr::Classes::Dungeon.new(elem)
					results[dungeon.id] = dungeon		if dungeon.id
					results[dungeon.key] = dungeon	if dungeon.key
				end
				
				(dungeon_strings_xml/:dungeon).each do |elem|
					id = elem[:id].to_i
					key = elem[:key]
					
					if (results[id])
						results[id].add_name_data(elem)
					elsif (results[key])
						results[key].add_name_data(elem)
					end					
				end
			else
				raise Wowr::Exceptions::InvalidXML.new()
      end
			
			return results
		end

		
		# Logs the user into the armory using their main world of warcraft username and password.
		# Returns a cookie string used for secure requests like get_guild_bank_contents and get_guild_bank_log.
		# Uses SSH to send details to the login page.
		def login(username, password)
			# url = 'https://eu.wowarmory.com/guild-bank-contents.xml?n=Rawr&r=Trollbane'
			url = base_url(@locale, {:secure => true}) + @@login_url
			
			req = Net::HTTP::Post.new(url)
			req["user-agent"] = "Mozilla/5.0 Gecko/20070219 Firefox/2.0.0.2" # ensure returns XML
			req["cookie"] = "cookieMenu=all; cookies=true;"
			
			uri = URI.parse(url)
			
			http = Net::HTTP.new(uri.host, uri.port)
			
			# Suppress "warning: peer certificate won't be verified in this SSL session"
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			http.use_ssl = true
			
			req.set_form_data({'accountName' => username, 'password' => password}, '&')
			
			
			http.start do
				res = http.request(req)
				
				tries = 0
				response = case res
					when Net::HTTPSuccess, Net::HTTPRedirection
						res.body
					else
						tries += 1
						if tries > @@max_connection_tries
							raise Wowr::Exceptions::NetworkTimeout.new('Timed out')
						else
							retry
						end
					end
				
				doc = Hpricot.XML(response)
				
				# error = 0 nothing provided
				# error = 1 invalid credentials
				# TODO: Detect different kinds of errors
				if (doc%'login')
					raise Wowr::Exceptions::InvalidLoginDetails
				else
					cookie = nil
					res.header['set-cookie'].scan(/JSESSIONID=(.*?);/) {
						cookie = 'JSESSIONID=' + $1 + ';'
					}
					return cookie
				end
			end
		end
		
		
		
		# Clear the cache, optional directory name.
		# * cache_path (String) Relative path of the cache directory to be deleted
		def clear_cache(cache_path = @@cache_directory_path)
			begin
				FileUtils.remove_dir(cache_path)
			rescue Exception => e 
				
			end
		end
		
		
		# Return the base url for the armory, e.g. http://eu.wowarmory.com/
		# * locale (String) The locale, defaults to that specified in the API constructor
		def base_url(locale = @locale, options = {})
			str = ""
			
			if (options[:secure] == true)
				str += 'https://'
			else
				str += 'http://'
			end
			
			if (locale == 'us')
				str += 'www.' + @@armory_base_url
			else
				str += locale + '.' + @@armory_base_url
			end
			
			return str
		end
		
		
		protected
		
		# Merge the defaults specified in the constructor with those supplied,
		# overriding any defaults with those supplied
		def merge_defaults(options = {})
			defaults = {}
			# defaults[:character_name] = @charater_name if @charater_name
			# defaults[:guild_name]	= @guild_name if @guild_name
			defaults[:realm] 					= @realm 					if @realm
			defaults[:locale] 				= @locale 				if @locale
			defaults[:lang] 					= @lang 					if @lang
			defaults[:caching] 				= @caching 				if @caching
			defaults[:cache_timeout] 	= @cache_timeout 	if @cache_timeout
			defaults[:debug] 					= @debug 					if @debug
			
			# overwrite defaults with any given options
			defaults.merge!(options)
		end
		
		# Return an Hpricot document for the given URL
		# TODO: Tidy up?
		def get_xml(url, options = {})
			
			# better way of doing this?
			# Map custom keys to the HTTP request values
			reqs = {
				:character_name => 'n',
				:realm => 'r',
				:search => 'searchQuery',
				:type => 'searchType',
				:guild_name => 'n',
				:item_id => 'i',
				:team_size => 'ts',
				:team_name => 't',
				:group => 'group'
			}
			
			
			params = []
			options.each do |key, value|
				params << "#{reqs[key]}=#{u(value)}" if reqs[key]
			end
			
			query = ''
			query = query + '?' + params.join('&') if params.size > 0
			#query = '?' + params.join('&') if params.size > 0
			
			base = self.base_url(options[:locale], options)
			full_query = base + url + query
			
			if options[:caching]
				response = get_cache(full_query, options)
			else
				response = http_request(full_query, options)
			end
						
			doc = Hpricot.XML(response)
			errors = doc.search("*[@errCode]")
			if errors.size > 0
				errors.each do |error|
					raise Wowr::Exceptions::raise_me(error[:errCode], options)
				end

			elsif (doc%'dungeons')
				return doc
			elsif (doc%'page').nil?
				raise Wowr::Exceptions::EmptyPage
			else
				return (doc%'page')
			end
		end
		
		
		# Perform an HTTP request and return the contents of the document
		def http_request(url, options = {})
			req = Net::HTTP::Get.new(url)
			req["user-agent"] = @@user_agent # ensure returns XML
			req["cookie"] = "cookieMenu=all; cookieLangId=" + options[:lang] + "; cookies=true;"
			
			req["cookie"] += options[:cookie] if options[:cookie]
			
			uri = URI.parse(url)
			
			http = Net::HTTP.new(uri.host, uri.port)
			
			if (options[:secure])
				puts "Secure authentication" if options[:debug]

				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
				http.use_ssl = true
			end
		  
			
			begin
				tries = 0
			  http.start do
			    res = http.request req
					# response = res.body
					
					response = case res
						when Net::HTTPSuccess, Net::HTTPRedirection
							res.body
						else
							tries += 1
							if tries > @@max_connection_tries
								raise Wowr::Exceptions::NetworkTimeout.new('Timed out')
							else
								retry
							end
						end
			  end
			rescue 
				raise Wowr::Exceptions::ServerDoesNotExist.new('Specified server at ' + url + ' does not exist.');
			end
		end
		
		
		# Translate the specified URL to the cache location, and return the file
		# If the cache does not exist, get the contents using http_request and create it
		def get_cache(url, options = {})
			path = cache_path(url, options)
				
			# file doesn't exist, make it
			if !File.exists?(path) ||
					options[:refresh_cache] ||
					(File.mtime(path) < Time.now - @cache_timeout)
					
				if options[:debug]
					if !File.exists?(path)
						puts 'Cache doesn\'t exist, making: ' + path
					elsif (File.mtime(path) < Time.now - @cache_timeout)
						puts 'Cache has expired, making again, making: ' + path
					elsif options[:refresh_cache]
						puts 'Forced refresh of cache, making: ' + path
					end
				end
				
				# make sure dir exists
				FileUtils.mkdir_p(localised_cache_path(options[:lang])) unless File.directory?(localised_cache_path(options[:lang]))
				
				xml_content = http_request(url, options)
				
				# write the cache
				file = File.open(path, File::WRONLY|File::TRUNC|File::CREAT)
				file.write(xml_content)
				file.close
			
			# file exists, return the contents
			else
				puts 'Cache already exists, read: ' + path if options[:debug]
				
				file = File.open(path, 'r')
				xml_content = file.read
				file.close
			end
			return xml_content
		end
		
		
		def cache_path(url, options)
			@@cache_directory_path + options[:lang] + '/' + url_to_filename(url)
		end
		
		
		# remove http://*.wowarmory.com/ leaving just xml file part and request parameters
		# Kind of assuming incoming URL is the same as the current locale
		def url_to_filename(url) #:nodoc:
			temp = url.gsub(base_url(), '')
			temp.gsub!('/', '.')
			return temp
		end
		
		
		
		def localised_cache_path(lang = @lang) #:nodoc:
			return @@cache_directory_path + lang
		end
		
		
		
		def u(str) #:nodoc:
			if str.instance_of?(String)
				return CGI.escape(str)
			else
				return str
			end
		end
	end
end
