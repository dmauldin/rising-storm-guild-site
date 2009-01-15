$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.dirname(__FILE__))

# TODO: This class requires some thought as its source is different to others
# 			The data source for other classes are single XML files that contain
# 			information relevant to the request.
# 			Dungeon data is stored in two large (7kb each) files.
# 			Even with caching this is going to be slow as the entire XML file has
# 			to be read in and built even for a single look-up.

module Wowr
	module Classes
		class Dungeon
			attr_reader :id, :key, :name,
			 						:level_minimum, :level_maximum,
									:party_size, :raid,
									:release, :heroic, :bosses
			
			alias_method :to_s, :name
			alias_method :to_i, :id
			alias_method :max_level, :level_maximum
			alias_method :min_level, :level_minimum
			
			def initialize(elem)				
				@id							= elem[:id].to_i
				@key						= elem[:key]
				@level_minimum	= elem[:levelMin].to_i
				@level_maximum	= elem[:levelMax].to_i
				@party_size			= elem[:partySize].to_i
				@raid						= (elem[:raid].to_i == 1) ? true : false
				@release				= elem[:release].to_i
				@heroic					= (elem[:hasHeroic].to_i == 1) ? true : false
				
				# Ideally want to be able to get the boss by both ID and key
				#	but by using normal hash.
				# After a test it seems the method below creates 2 references to an object.
				@bosses = {}
				
				(elem/:boss).each do |elem|
					# TODO: Is this insane?
					#				After object test, appears this will be references to the same object
					boss = Boss.new(elem)
					@bosses[boss.id]	= boss	if boss.id
					@bosses[boss.key]	= boss	if boss.key
				end
			end
			
			# Add the name data from dungeonStrings.xml
			def add_name_data(elem)
				# puts elem.raw_string.to_yaml
				@name = elem.attributes["name"]
				
				(elem/:boss).each do |boss_elem|
					id = boss_elem[:id].to_i
					key = boss_elem[:key]
					
					@bosses[id].add_name_data(boss_elem)	if id
					@bosses[key].add_name_data(boss_elem)	if key
				end
			end
		end


		# Note Key or id can be nil
		# Not both
		class Boss
			attr_reader :id, :key, :name, :type
			
			alias_method :to_s, :name
			alias_method :to_i, :id
			
			def initialize(elem)				
				@id			= elem[:id].to_i if elem[:id].to_i
				@key		= elem[:key] if elem[:key]
				@id			= @key if !elem[:id].to_i
				
				@type			= elem[:type]
			end
			
			def add_name_data(elem)
				@name = elem['name']
			end
		end
	end
end
