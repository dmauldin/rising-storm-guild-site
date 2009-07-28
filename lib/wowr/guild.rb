$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'character.rb'

module Wowr #:nodoc:
	module Classes #:nodoc:
		
		# A player guild containing members
		# Abstract
		class Guild
			attr_reader :name, :url, :realm
									# :roster_url, :stats_url, :stats_url_escape,
			alias_method :to_s, :name

			def initialize(elem)
				if (elem%'guildHeader')
					guild = (elem%'guildHeader')
				else
					guild = elem
				end
				
				@name					= guild[:name]
				@url					= guild[:url]
				@realm				= guild[:realm]
			end
		end
		
		# Basic search information returned by the search.xml
		# <guilds>
		#   <guild
		# battleGroup="Ruin"
		# faction="Alliance"
		# factionId="0"
		# name="HAND"
		# realm="Stormrage"
		# relevance="100"
		# url="r=Stormrage&amp;n=HAND&amp;p=1"/>
		# </guilds>
		class SearchGuild < Guild
			attr_reader :faction, :faction_id, :battle_group
			
			def initialize(elem)
				super(elem)
				
				@battle_group = elem[:battleGroup]
				@faction			= elem[:faction]
				@faction_id		= elem[:factionId].to_i
				
				@relevance		= elem[:relevance].to_i
			end
		end
		
		# Full guild data
		# <guildKey factionId="0" name="HAND" nameUrl="HAND" realm="Stormrage" realmUrl="Stormrage" url="r=Stormrage&amp;n=HAND"/>
	  # <guildInfo>
	  #   <guild>
	  #     <members filterField="" filterValue="" maxPage="1" memberCount="1" page="1" sortDir="a" sortField="">
	  #       <character class="Paladin" classId="2" gender="Male" genderId="0" level="14" name="Sturky" race="Dwarf" raceId="3" rank="0" url="r=Stormrage&amp;n=Sturky"/>
	  #     </members>
	  #   </guild>
	  # </guildInfo>
		class FullGuild < Guild
			attr_reader :members, :name_url, :realm_url, :member_count
		
			def initialize(elem)
				super(elem)
				
				@name_url			= elem[:nameUrl]
				@realm_url		= elem[:realmUrl]
				
				# Guild/guild_id/guild_url not set for characters
				if (elem%'guildInfo')
					@member_count = (elem%'guildInfo'%'guild'%'members')[:memberCount].to_i || nil
					@members = {}
					(elem%'guildInfo'%'guild'%'members'/:character).each do |char|
						# TODO: Change to search character?
						members[char[:name]] = Character.new(char)
					end
				end
			end
		
		end
	end
end
