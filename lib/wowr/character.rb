$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'wowr/item.rb'

module Wowr
	module Classes

		# Short character info, used in guild lists etc.
		# Note that the way that searches and character listings within guilds works,
		# there can be a variable amount of information filled in within the class.
		# Guild listings and search results contain a smaller amount of information than
		# single queries
		# Attributes
		# * name (String) - Full character name
		# * level (Fixnum) - Level
    # See Also: Guild
		class Character
			attr_reader :name, :level, :url, :rank,
									:klass, :klass_id,
									:gender, :gender_id,
									:race, :race_id,
									:guild, :guild_id, :guild_url,
									:realm,
									:battle_group, :last_login,
									:relevance, :search_rank,
									:achievement_points,
									
									:season_games_played, :season_games_won, :team_rank, :contribution # From ArenaTeam info
			
			alias_method :to_s, :name
			alias_method :to_i, :level
			
			@@race_icon_url_base = 'images/icons/race/'
			@@class_icon_url_base = 'images/icons/class/'
			@@portrait_url_base = 'images/portraits/'
			@@icon_types = {:default => 'wow-default', 70 => 'wow-70', :other => 'wow'}
			
			def initialize(elem, api = nil)
				@api = api
				
				@name	 			= elem[:name]
				@level 			= elem[:level].to_i
				@url 				= elem[:url] || elem[:charUrl]
				@rank 			= elem[:rank].to_i
				
				@klass 			= elem[:class]
				@klass_id		= elem[:classId].to_i
				
				@gender 		= elem[:gender]
				@gender_id 	= elem[:genderId].to_i
				
				@race 			= elem[:race]
				@race_id 		= elem[:raceId].to_i
				
				@guild			= elem[:guild] == "" ? nil : elem[:guild]
				@guild_id		= elem[:guildId].to_i == 0 ? nil : elem[:guildId].to_i
				@guild_url	= elem[:guildUrl] == "" ? nil : elem[:guildUrl]
				
				@realm			= elem[:realm] == "" ? nil : elem[:realm]
				
				@battle_group 		= elem[:battleGroup] == "" ? nil : elem[:battleGroup]
				@battle_group_id 	= elem[:battleGroupId].to_i
				
				@relevance 		= elem[:relevance].to_i
				@search_rank 	= elem[:searchRank].to_i
				
				@achievement_points = elem[:points].to_i if elem[:points]
				@achievement_points = elem[:achPoints].to_i if elem[:achPoints]
				
				# Incoming string is 2007-02-24 20:33:04.0, parse to datetime
				#@last_login 	= elem[:lastLoginDate] == "" ? nil : DateTime.parse(elem[:lastLoginDate])
				@last_login 	= elem[:lastLoginDate] == "" ? nil : elem[:lastLoginDate]
				
				# From ArenaTeam info, can be blank on normal requests
				#<character battleGroup="" charUrl="r=Draenor&amp;n=Lothaar" class="Paladin" classId="2"
				# contribution="1602" gamesPlayed="10" gamesWon="7" gender="Male" genderId="0"
				# guild="Passion" guildId="36659" guildUrl="r=Draenor&amp;n=Passion&amp;p=1" name="Lothaar"
				# race="Human" raceId="1" seasonGamesPlayed="20" seasonGamesWon="13" teamRank="1"/>
				@season_games_played 	= elem[:seasonGamesPlayed] == "" ? nil : elem[:seasonGamesPlayed].to_i
				@season_games_won 		= elem[:seasonGamesWon] == "" ? nil : elem[:seasonGamesWon].to_i
				@team_rank 						= elem[:teamRank] == "" ? nil : elem[:teamRank].to_i
				@contribution					= elem[:contribution] == "" ? nil : elem[:contribution].to_i
				#@char_url 						= elem[:charUrl]	# TODO: Merge with URL?
			end
			
			
			def icon(type = nil)
				if !type.nil? && !@@icon_types.include?(type)
					raise Wowr::Exceptions::InvalidIconType.new(@@icon_types)
				end
				
				if (type.nil?) && (@level == 70)
					dir = @@icon_types[70]
				elsif (type.nil?)
					dir = @@icon_types[:other]
				else
					dir = @@icon_types[type]
				end
				
				# http://armory.worldofwarcraft.com/images/portraits/wow-70/1-7-8.gif
				return base + @@portrait_url_base + dir + "/#{@gender_id}-#{@race_id}-#{@klass_id}.gif"
			end
			
			
			def race_icon
				# http://armory.worldofwarcraft.com/images/icons/race/11-1.gif
				return base + @@race_icon_url_base + "#{@race_id}-#{@gender_id.to_s}.gif"
			end
			
			
			def class_icon
				# http://armory.worldofwarcraft.com/images/icons/class/8.gif
				return base + @@class_icon_url_base + "#{@klass_id.to_s}.gif"
			end
			
			
			protected
			def base
				if @api
					return @api.base_url
				else
					return 'http://www.wowarmory.com/'
				end
			end
		end
		
		class	SearchCharacter < Character
		end
		
    # Character details without reputations
    # uses characterInfo element
		# Made up of two parts, character and charactertab
		class InfoCharacter < Character
			
			# character_info
			attr_reader :char_url, 
			             :title, :known_titles,
									:faction, :faction_id,
			 						:arena_teams,
									:last_modified,
									:points
			
			# character_tab
			attr_reader :health, :second_bar,
									:strength, :agility, :stamina, :intellect, :spirit
			alias_method :str, :strength
			alias_method :agi, :agility
			alias_method :sta, :stamina
			alias_method :int, :intellect
			alias_method :spi, :spirit
			
			attr_reader :melee, :ranged, :spell,
									:defenses, :resistances,
									:talent_spec, :all_talent_specs, :pvp,
									:professions,
									:items,
									:buffs, :debuffs
			
			# It's made up of two parts
			# Don't care about battlegroups yet
			# I don't think I can call stuff from the constructor?
			def initialize(sheet, api = nil)
				super(sheet%'character', api)
				
				@api = api
				
				character_info(sheet%'character')
				
				# Check if characterTab is defined. If not, the character have no infos on the armory (not logged since last armory wipe)
				raise Wowr::Exceptions::CharacterNoInfo.new(@name) if (sheet%'characterTab').nil?
				
				character_tab(sheet%'characterTab')
			end
			
			# <character
			#  battleGroup="Conviction"
			#  charUrl="r=Genjuros&amp;n=Jonlok"
			#  class="Warlock"
			#  classId="9"
			#  faction="Horde"
			#  factionId="1"
			#  gender="Male"
			#  genderId="0"
			#  guildName=""
			#  lastModified="12 February 2008"
			#  level="41"
			#  name="Jonlok"
			#  prefix="" 
			#  points="2270"
			#  race="Orc"
			#  raceId="2"
			#  realm="Genjuros"
			#  suffix=""/>

			def character_info(elem)
				# basic info
				@name	 			= elem[:name]
				@level 			= elem[:level].to_i
				@char_url 	= elem[:charUrl]
				
				@klass 			= elem[:class]
				@klass_id		= elem[:classId].to_i

				@gender 		= elem[:gender]
				@gender_id 	= elem[:genderId].to_i

				@race 			= elem[:race]
				@race_id 		= elem[:raceId].to_i
				
				@faction 		= elem[:faction]
				@faction_id = elem[:factionId].to_i
				
				@guild			= elem[:guildName] == "" ? nil : elem[:guildName]
				@guild_url	= elem[:guildUrl] == "" ? nil : elem[:guildUrl]
				
				@prefix			= elem[:prefix] == "" ? nil : elem[:prefix]
				@suffix			= elem[:suffix] == "" ? nil : elem[:suffix]
				
				@points     = elem[:points].to_i
				
				@realm			= elem[:realm]
				
				@battle_group = elem[:battleGroup]
				
				# format is February 11, 2008
				# except when it's korean, and then it's 2008년 5월 11일 (일)
				# tw is 2008&#24180;5&#26376;11&#26085; (2008年5月11日)
				# TODO: Datetime doesn't parse other languages nicely
				# 			Until then, just save it as a string
				begin
					@last_modified 	= elem[:lastModified] == "" ? nil : DateTime.parse(elem[:lastModified])
				rescue
					@last_modified 	= elem[:lastModified] == "" ? nil : elem[:lastModified]
				end
				#@last_modified = elem[:lastModified]#.to_time
				
				@arena_teams = []
				(elem/:arenaTeam).each do |arena_team|
					@arena_teams << ArenaTeam.new(arena_team)
				end
				
			end
			
			def character_tab(elem)
				# <title value=""/>
				#@title				= (elem%'title')[:value] == "" ? nil : (elem%'title')[:value]
				if (@prefix || @suffix)
				  @title = (@prefix ? @prefix : "") + "%s" + (@suffix ? @suffix : "") 
				end


				@known_titles = []

				@known_titles << @title if (@title)

				#@known_titles << @title if (@title)
				#(elem%'knownTitles'/:title).each do |entry|
				#  @known_titles << entry[:value] if (!@known_titles.include?(entry[:value]))
				#end

				@health 		= (elem%'characterBars'%'health')[:effective].to_i
				@second_bar = SecondBar.new(elem%'characterBars'%'secondBar')
				
				# base stats
				@strength 	= Strength.new(elem%'baseStats'%'strength')
				@agility 		= Agility.new(elem%'baseStats'%'agility')
				@stamina 		= Stamina.new(elem%'baseStats'%'stamina')
				@intellect 	= Intellect.new(elem%'baseStats'%'intellect')
				@spirit 		= Spirit.new(elem%'baseStats'%'spirit')
				
				# damage stuff
				@melee 		= Melee.new(elem%'melee')
				@ranged 	= Ranged.new(elem%'ranged')
				@spell 		= Spell.new(elem.at(' > spell'))	# TODO: hacky?
				@defenses = Defenses.new(elem%'defenses')
				
				# TODO: Massive problem, doesn't fill in resistances for some reason
				resist_types = ['arcane', 'fire', 'frost', 'holy', 'nature', 'shadow']
				@resistances = {}
				resist_types.each do |res|
					@resistances[res] = Resistance.new(elem%'resistances'%res)
				end
				
				@all_talent_specs = []
				
				(elem%'talentSpecs'/:talentSpec).each do |spec|
				   new_spec = TalentSpec.new(spec)
				   @all_talent_specs << new_spec
				   
				   @talent_spec = new_spec if (new_spec.active)
				end
				
				@pvp = Pvp.new(elem%'pvp')
								
				@professions = []
				(elem%'professions'/:skill).each do |skill|
					@professions << Skill.new(skill)
				end
				
				@items = []
				(elem%'items'/:item).each do |item|
					@items << EquippedItem.new(item, @api)
				end
				
				@buffs = []
				(elem%'buffs'/:spell).each do |buff|
					@buffs << Buff.new(buff, @api)
				end
				
				@debuffs = []
				(elem%'debuffs'/:spell).each do |debuff|
					@debuffs << Buff.new(debuff, @api)
				end
			end
		end
		
		# Full character details with reputations
		class FullCharacter < InfoCharacter
		  attr_reader :reputation_categories
			
			alias_method :rep, :reputation_categories
			alias_method :reputation, :reputation_categories
			
			def initialize(sheet, reputation, api = nil)
				@api = api
			
			  # Build the InfoCharacter
			  super(sheet, api)
			  
			  # Add reputations
				character_reputation(reputation)
			end
			
			# character-reputation.xml
			def character_reputation(elem)
  			@reputation_categories = {}
  			(elem/:factionCategory).each do |category|
  				@reputation_categories[category[:key]] = RepFactionCategory.new(category)
  			end
			end
	  end
		
		
		# Second stat bar, depends on character class
		class SecondBar
			attr_reader :effective, :casting, :not_casting, :type
			
			def initialize(elem)
				@effective 		= elem[:effective].to_i
				@casting 			= elem[:casting].to_i == -1 ? nil : elem[:casting].to_i
				@not_casting 	= elem[:notCasting].to_i == -1 ? nil : elem[:notCasting].to_i
				@type 				= elem[:type]
			end
		end
		
		
		class BaseStat	# abstract?
			attr_reader :base, :effective
		end
		
		class Strength < BaseStat
			attr_reader :attack, :block
			def initialize(elem)
				@base				= elem['base'].to_i
				@effective 	= elem['effective'].to_i
				@attack 		= elem['attack'].to_i
				@block 			= elem['block'].to_i == -1 ? nil : elem['block'].to_i
			end
		end
		
		class Agility < BaseStat
			attr_reader :armor, :attack, :crit_hit_percent
			def initialize(elem)
				@base	 		 				= elem[:base].to_i
				@effective 				= elem[:effective].to_i
				@armor 		 				= elem[:armor].to_i
				@attack 					= elem[:attack].to_i == -1 ? nil : elem[:attack].to_i
				@crit_hit_percent = elem[:critHitPercent].to_f
			end
		end
		
		class Stamina < BaseStat
			attr_reader :health, :pet_bonus
			def initialize(elem)
				@base 			= elem[:base].to_i
				@effective 	= elem[:effective].to_i
				@health 		= elem[:health].to_i
				@pet_bonus 	= elem[:petBonus].to_i == -1 ? nil : elem[:petBonus].to_i
			end
		end
		
		class Intellect < BaseStat
			attr_reader :mana, :crit_hit_percent, :pet_bonus
			def initialize(elem)
				@base	 						= elem[:base].to_i
				@effective 				= elem[:effective].to_i
				@mana 						= elem[:mana].to_i
				@crit_hit_percent = elem[:critHitPercent].to_f
				@pet_bonus 				= elem[:petBonus].to_i == -1 ? nil : elem[:petBonus].to_i
			end
		end
		
		class Spirit < BaseStat
			attr_reader :health_regen, :mana_regen
			def initialize(elem)
				@base	 				= elem[:base].to_i
				@effective 		= elem[:effective].to_i
				@health_regen = elem[:healthRegen].to_i
				@mana_regen 	= elem[:manaRegen].to_i
			end
		end
		
		class Armor < BaseStat
			attr_reader :percent, :pet_bonus
			def initialize(elem)
				@base 			= elem[:base].to_i
				@effective 	= elem[:effective].to_i
				@percent 		= elem[:percent].to_f
				@pet_bonus 	= elem[:petBonus].to_i == -1 ? nil : elem[:petBonus].to_i
			end
		end
		
		
		
		# <melee>
		# 	<mainHandDamage dps="65.6" max="149" min="60" percent="0" speed="1.60"/>
		# 	<offHandDamage dps="0.0" max="0" min="0" percent="0" speed="2.00"/>
		# 	<mainHandSpeed hastePercent="0.00" hasteRating="0" value="1.60"/>
		# 	<offHandSpeed hastePercent="0.00" hasteRating="0" value="2.00"/>
		# 	<power base="338" effective="338" increasedDps="24.0"/>
		# 	<hitRating increasedHitPercent="0.00" value="0"/>
		# 	<critChance percent="4.16" plusPercent="0.00" rating="0"/>
		# 	<expertise additional="0" percent="0.00" rating="0" value="0"/>
		# </melee>
		class Melee
			attr_reader :main_hand_skill, :off_hand_skill,
									:main_hand_damage, :off_hand_damage,
									:main_hand_speed, :off_hand_speed,
									:power, :hit_rating, :crit_chance,
									:expertise

			def initialize(elem)
				# TODO: Do these not exist anymore?
				@main_hand_skill 	= WeaponSkill.new(elem%'mainHandWeaponSkill') if (elem%'mainHandWeaponSkill')
				@off_hand_skill 	= WeaponSkill.new(elem%'offHandWeaponSkill') if (elem%'offHandWeaponSkill')
				
				@main_hand_damage = WeaponDamage.new(elem%'mainHandDamage')
				@off_hand_damage 	= WeaponDamage.new(elem%'offHandDamage')
				
				@main_hand_speed 	= WeaponSpeed.new(elem%'mainHandSpeed')
				@off_hand_speed 	= WeaponSpeed.new(elem%'offHandSpeed')
				
				@power 						= WeaponPower.new(elem%'power')
				@hit_rating 			= WeaponHitRating.new(elem%'hitRating')
				@crit_chance 			= WeaponCritChance.new(elem%'critChance')
				
				@expertise 				= WeaponExpertise.new(elem%'expertise')
			end
		end

		# <ranged>
		# 	<weaponSkill rating="0" value="-1"/>
		# 	<damage dps="0.0" max="0" min="0" percent="0" speed="0.00"/>
		# 	<speed hastePercent="0.00" hasteRating="0" value="0.00"/>
		# 	<power base="57" effective="57" increasedDps="4.0" petAttack="-1.00" petSpell="-1.00"/>
		# 	<hitRating increasedHitPercent="0.00" value="0"/>
		# 	<critChance percent="0.92" plusPercent="0.00" rating="0"/>
		# </ranged>
		class Ranged
			attr_reader :weapon_skill, :damage, :speed, :power,
									:hit_rating, :crit_chance

			def initialize(elem)
				@weapon_skill = WeaponSkill.new(elem%'weaponSkill')
				@damage 			= WeaponDamage.new(elem%'damage')
				@speed 				= WeaponSpeed.new(elem%'speed')
				@power 				= WeaponPower.new(elem%'power')
				@hit_rating 	= WeaponHitRating.new(elem%'hitRating')
				@crit_chance 	= WeaponCritChance.new(elem%'critChance')
			end
		end
			
		class WeaponSkill
			attr_reader :rating, :value
			
			def initialize(elem)
				@value 	= elem[:value].to_i == -1 ? nil : elem[:value].to_i
				@rating = elem[:rating].to_i
			end
		end
		
		class WeaponDamage
			attr_reader :dps, :max, :min, :percent, :speed
			
			def initialize(elem)
				@dps 			= elem[:dps].to_f
				@max 			= elem[:max].to_i
				@min 			= elem[:min].to_i
				@percent 	= elem[:percent].to_f
				@speed 	= elem[:speed].to_f
			end
		end
		
		class WeaponSpeed
			attr_reader :haste_percent, :haste_rating, :value
			
			def initialize(elem)
				@haste_percent 	= elem[:hastePercent].to_f
				@haste_rating 	= elem[:hasteRating].to_f
				@value 				= elem[:value].to_f
			end
		end
		
		class WeaponPower
			attr_reader :base, :effective, :increased_dps, :pet_attack, :pet_spell, :haste_rating
			
			def initialize(elem)
				@base 					= elem[:base].to_i
				@haste_rating 	= elem[:effective].to_i
				@increased_dps 	= elem[:increasedDps].to_f
				@pet_attack 		= (elem[:petAttack].to_f == -1 ? nil : elem[:petAttack].to_f)
				@pet_spell 			= (elem[:petSpell].to_f == -1 ? nil : elem[:petSpell].to_f)					
			end
		end
		
		class WeaponHitRating
			attr_reader :increased_hit_percent, :value
			
			def initialize(elem)
				@increased_hit_percent 	= elem[:increasedHitPercent].to_f
				@value 									= elem[:value].to_f
			end
		end
		
		class WeaponCritChance
			attr_reader :percent, :plus_percent, :rating
			
			def initialize(elem)
				@percent 			= elem[:percent].to_f
				@plus_percent = elem[:plusPercent].to_f
				@rating 			= elem[:rating].to_i
			end
		end
		
		# <expertise additional="0" percent="0.00" rating="0" value="0"/>
		class WeaponExpertise
			attr_reader :additional, :percent, :rating, :value
			
			def initialize(elem)
				@additional	= elem[:additional].to_i
				@percent 		= elem[:percent].to_f
				@rating 		= elem[:rating].to_i
				@value			= elem[:value].to_i
			end
		end
		
		
		# Decided to do funky stuff to the XML to make it more useful.
		# instead of having two seperate lists of bonusDamage and critChance
		# merged it into one set of objects for each thing
		class Spell
			attr_reader :arcane, :fire, :frost, :holy, :nature, :shadow,
									:hit_rating, :bonus_healing, :penetration, :mana_regen, :speed
			
			def initialize(elem)
				@arcane = SpellDamage.new(elem%'bonusDamage'%'arcane', elem%'critChance'%'arcane')
				@fire   = SpellDamage.new(elem%'bonusDamage'%'fire', elem%'critChance'%'fire')
				@frost  = SpellDamage.new(elem%'bonusDamage'%'frost', elem%'critChance'%'frost')
				@holy   = SpellDamage.new(elem%'bonusDamage'%'holy', elem%'critChance'%'holy')
				@nature = SpellDamage.new(elem%'bonusDamage'%'nature', elem%'critChance'%'nature')
				@shadow = SpellDamage.new(elem%'bonusDamage'%'shadow', elem%'critChance'%'shadow')

				@bonus_healing 	= (elem%'bonusHealing')[:value].to_i # is this right??
				@penetration 		= (elem%'penetration')[:value].to_i
				@hit_rating 		= WeaponHitRating.new(elem%'hitRating')
				@mana_regen 		= ManaRegen.new(elem%'manaRegen')
				@speed 			= SpellSpeed.new(elem%'hasteRating')
				
				# elements = %w[arcane fire frost holy nature shadow]
				# elements.each do |element|
				# 	# TODO: is this a good idea?
				# 	#instance_variable_set("@#{element}", foo) #??
				# 	#eval("@#{element} = SpellDamage.new(elem[:bonusDamage][element][:value], elem[:critChance][element][:percent]).to_f)")
				# 	# eval("@#{element} = SpellDamage.new((elem%'bonusDamage'%element)[:value].to_i,
				# 	# 																						(elem%'critChance'%element)[:percent].to_f)")
				# end
			end
		end

		class SpellSpeed
			attr_reader :percent_increase, :haste_rating
	
			def initialize(elem)
				@percent_increase	= elem[:hastePercent].to_f
				@haste_rating 	= elem[:hasteRating].to_i
			end
		end
		
		class SpellDamage
			attr_reader :value, :crit_chance_percent
			alias_method :percent, :crit_chance_percent
			
			def initialize(bonusDamage_elem, critChance_elem)
				@value 		= bonusDamage_elem[:value].to_i
				@crit_chance_percent	= critChance_elem[:percent].to_f
			end
		end
		
		class ManaRegen
			attr_reader :casting, :not_casting
			
			def initialize(elem)
				@casting 			= elem[:casting].to_f
				@not_casting 	= elem[:notCasting].to_f
			end
		end
		
		class PetBonus
			attr_reader :attack, :damage, :from_Type
			
			def initialize(elem)
				@attack 		= elem[:attack].to_i == -1 ? nil : elem[:attack].to_i
				@damage 		= elem[:damage].to_i == -1 ? nil : elem[:damage].to_i
				@from_type 	= elem[:fromType] if elem[:fromType]
			end
		end
		
		
		
		class Defenses
			attr_reader :armor, :defense, :dodge, :parry, :block, :resilience
			
			def initialize(elem)
				@armor 			= Armor.new(elem%'armor')
				@defense 		= Defense.new(elem%'defense')
				@dodge 			= DodgeParryBlock.new(elem%'dodge')
				@parry 			= DodgeParryBlock.new(elem%'parry')
				@block 			= DodgeParryBlock.new(elem%'block')
				@resilience = Resilience.new(elem%'resilience')
			end
		end
		
		class Armor
			attr_reader :base, :effective, :percent, :pet_bonus
			
			def initialize(elem)
				@base 			= elem[:base].to_i
				@effective 	= elem[:effective].to_i
				@percent 		= elem[:percent].to_f
				@pet_bonus 	= elem[:petBonus].to_i == -1 ? nil : elem[:petBonus].to_i
			end
		end
		
		class Defense
			attr_reader :value, :increase_percent, :decrease_percent, :plus_defense, :rating
			
			def initialize(elem)
				@value 						= elem[:value].to_i
				@increase_percent = elem[:increasePercent].to_f
				@decrease_percent = elem[:decreasePercent].to_f
				@plus_defense 		= elem[:plusDefense].to_i
				@rating 					= elem[:rating].to_i
			end
		end
		
		class DodgeParryBlock
			attr_reader :percent, :increase_percent, :rating
			
			def initialize(elem)
				@percent 					= elem[:percent].to_f
				@increase_percent = elem[:increasePercent].to_f
				@rating 					= elem[:rating].to_i
			end
		end
		
		class Resilience
			attr_reader :damage_percent, :hit_percent, :value
			
			def initialize(elem)
				@damage_percent = elem[:damagePercent].to_f
				@hit_percent 		= elem[:hitPercent].to_f
				@value 					= elem[:value].to_f
			end
		end
		
		
		class Resistance
			attr_reader :value, :pet_bonus
			
			def initialize(elem)
				@value 			= elem[:value].to_i
				@pet_bonus 	= elem[:petBonus].to_i == -1 ? nil : elem[:petBonus].to_i
			end
		end
		
		
		# Note the list of talent trees starts at 1. This is quirky, but that's what's used in the XML
		class TalentSpec
			attr_reader :trees, :active, :group, :primary

			def initialize(elem)
				@trees = []
				@trees[1] = elem[:treeOne].to_i
				@trees[2] = elem[:treeTwo].to_i
				@trees[3] = elem[:treeThree].to_i
				@active = (elem[:active].to_i == 1 ? true : false)
				@group = elem[:group].to_i
				@primary = elem[:prim]
			end
		end
		
		
		# Player-versus-player data
		class Pvp
			attr_reader :lifetime_honorable_kills, :arena_currency
			
			def initialize(elem)
				@lifetime_honorable_kills = (elem%'lifetimehonorablekills')[:value].to_i
				@arena_currency 					= (elem%'arenacurrency')[:value].to_i
			end
		end
		
				
		# A buff 
		# TODO: Code duplication, see basic Item class. Make extend Icon class?
		class Buff
			attr_reader :name, :effect, :icon_base
			alias_method :to_s, :name
			
			@@icon_url_base = 'images/icons/'
			@@icon_sizes = {:large => ['64x64', 'jpg'], :medium => ['43x43', 'png'], :small => ['21x21', 'png']}
			
			def initialize(elem, api = nil)
				@api = api
				
				@name 			= elem[:name]
				@effect			= elem[:effect]
				@icon_base	= elem[:icon]
			end
			
			# http://armory.worldofwarcraft.com/images/icons/21x21/spell_holy_arcaneintellect.png
			def icon(size = :medium)
				if !@@icon_sizes.include?(size)
					raise Wowr::Exceptions::InvalidIconSize.new(@@icon_sizes)
				end
				
				if @api
					base = @api.base_url
				else
					base = 'http://www.wowarmory.com/'
				end
				
				# http://www.wowarmory.com/images/icons/64x64/blahblah.jpg
				return base + @@icon_url_base + @@icon_sizes[size][0] + '/' + @icon_base + '.' + @@icon_sizes[size][1]
			end
		end
		
		
		# An item equipped to a player
		class EquippedItem < Item
			attr_reader :durability, :max_durability, #:id, :item_id, :icon,
									:gems, :permanent_enchant,
									:random_properties_id, :seed, :slot
			
			def initialize(elem, api = nil)
				super(elem, api)
				@durability						= elem[:durability].to_i
				@max_durability				= elem[:maxDurability].to_i
				@gems = []
				@gems[0]							= elem[:gem0Id].to_i == 0 ? nil : elem[:gem0Id].to_i
				@gems[1]							= elem[:gem1Id].to_i == 0 ? nil : elem[:gem1Id].to_i
				@gems[2]							= elem[:gem2Id].to_i == 0 ? nil : elem[:gem2Id].to_i
				@permanent_enchant		= elem[:permanentenchant].to_i
				@random_properties_id = elem[:randomPropertiesId] == 0 ? nil : elem[:randomPropertiesId].to_i
				@seed									= elem[:seed].to_i # not sure if seed is so big it's overloading
				@slot									= elem[:slot].to_i
			end
		end


		# eg Daggers, Riding, Fishing, language
		class Skill
			attr_reader :key, :name, :value, :max
			alias_method :to_s, :name
			alias_method :to_i, :value
			
			def initialize(elem)
				@key 		= elem[:key]
				@name 	= elem[:name]
				@value 	= elem[:value].to_i
				@max 		= elem[:max].to_i
			end
		end
		
		
		# Larger group of factions
		# Used for faction information
		# eg Alliance, Shattrath City, Steamwheedle Cartel
		class RepFactionCategory
			attr_reader :key, :name, :factions
			alias_method :to_s, :name
			
			def initialize(elem)
				@key 	= elem[:key]
				@name = elem[:name]
				
				@factions = {}
				(elem/:faction).each do |faction|
					@factions[faction[:key]] = RepFaction.new(faction)
				end
			end
			
			def total
				total = 0
				factions.each_value { |faction| total += faction.reputation }
				return total
			end
		end
		
		
		# Smaller NPC faction that is part of a FactionCategory
		# eg Darnassus, Argent Dawn
		class RepFaction
			attr_reader :key, :name, :reputation
			alias_method :to_s, :name
			alias_method :to_i, :reputation
						
			alias_method :rep, :reputation
						
			def initialize(elem)
				@key 				= elem[:key]
				@name 			= elem[:name]
				@reputation = elem[:reputation].to_i
			end
		end
		
	end
end
