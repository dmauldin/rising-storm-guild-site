module Wowr
	module Classes
		class ArenaTeam
			attr_reader :name, :size, :battle_group, :faction, :faction_id, :realm, :realm_url, 
									:games_played, :games_won, :ranking, :rating,
									:season_games_played, :season_games_won, :last_season_ranking, 
									:relevance, :url, :url_escape,
									:characters,	# can be blank on search results
									:emblem
			alias_method :to_s, :name

			def initialize(elem)
				@name					= elem[:name]
				@size					= elem[:size].to_i
				@battle_group	= elem[:battleGroup]
				@faction			= elem[:faction]
				@faction_id		= elem[:factionId].to_i
				@realm				= elem[:realm]
				@realm_url		= elem[:realmUrl]

				@games_played	= elem[:gamesPlayed].to_i
				@games_won		= elem[:gamesWon].to_i
				# @ranking			= elem[:ranking].to_i # Ranking in the seach results is always 0
				@rating				= elem[:rating].to_i

				@season_games_played	= elem[:seasonGamesPlayed].to_i
				@season_games_won			= elem[:seasonGamesWon].to_i
				@last_season_ranking	= elem[:lastSeasonRanking].to_i

				@relevance		= elem[:relevance].to_i
				@url					= elem[:url]

				@emblem				= ArenaTeamEmblem.new(elem%'emblem')
			end
		end
		
		
		class SearchArenaTeam < ArenaTeam
			def initialize(elem)
				super(elem)
			end
		end
		
		# <teamInfo>
		# 	<arenaTeam battleGroup="Vindication" faction="Alliance" factionId="0" gamesPlayed="6" gamesWon="1" lastSeasonRanking="4118" name="Monkey" ranking="6522" rating="1535" realm="Burning Blade" realmUrl="b=Vindication&amp;r=Burning+Blade&amp;ts=2&amp;t=Monkey&amp;ff=realm&amp;fv=Burning+Blade&amp;select=Monkey" relevance="0" seasonGamesPlayed="66" seasonGamesWon="34" size="2" url="r=Burning+Blade&amp;ts=2&amp;t=Monkey&amp;select=Monkey" urlEscape="r=Burning+Blade&amp;ts=2&amp;t=Monkey&amp;select=Monkey">
		# 		<emblem background="ff70de56" borderColor="ffcc73eb" borderStyle="6" iconColor="ffe3b320" iconStyle="44"/>
		# 		<members>
		# 			<character battleGroup="Vindication" charUrl="r=Burning+Blade&amp;n=Fandiar" class="Priest" classId="5" contribution="1380" gamesPlayed="0" gamesWon="0" gender="Male" genderId="0" guild="Legends" guildId="916" guildUrl="r=Burning+Blade&amp;n=Legends&amp;p=1" name="Fandiar" race="Night Elf" raceId="4" realm="Burning Blade" seasonGamesPlayed="18" seasonGamesWon="1" teamRank="0"/>
		# 			<character battleGroup="Vindication" charUrl="r=Burning+Blade&amp;n=Stayfrosty" class="Mage" classId="8" contribution="1460" gamesPlayed="6" gamesWon="1" gender="Male" genderId="0" guild="Legends" guildId="916" guildUrl="r=Burning+Blade&amp;n=Legends&amp;p=1" name="Stayfrosty" race="Human" raceId="1" realm="Burning Blade" seasonGamesPlayed="6" seasonGamesWon="1" teamRank="1"/>
		# 			<character battleGroup="Vindication" charUrl="r=Burning+Blade&amp;n=Step" class="Rogue" classId="4" contribution="1688" gamesPlayed="2" gamesWon="1" gender="Female" genderId="1" guild="Legends" guildId="916" guildUrl="r=Burning+Blade&amp;n=Legends&amp;p=1" name="Step" race="Human" raceId="1" realm="Burning Blade" seasonGamesPlayed="44" seasonGamesWon="33" teamRank="1"/>
		# 		</members>
		# 	</arenaTeam>
		# </teamInfo>
		class FullArenaTeam < ArenaTeam
			
			def initialize(elem)
				super(elem)
				# @ranking			= elem[:ranking].to_i
				
				@members = {}
				(elem%'members'/:character).each do |character|
					@members[character[:name]] = SearchCharacter.new(character)
				end
			end
		end
		
		# An arena team's logo
		class ArenaTeamEmblem
			attr_reader :background, :border_color, :border_style, :icon_colour, :icon_style
			
			def initialize(elem)
				@background		= elem[:background]
				@border_color = elem[:borderColor]
				@border_style = elem[:borderStyle].to_i
				@icon_color		= elem[:iconColor]
				@icon_style		= elem[:iconStyle].to_i
			end
		end
	end
end