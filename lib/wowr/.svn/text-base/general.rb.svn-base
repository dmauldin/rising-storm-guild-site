$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.dirname(__FILE__))

module Wowr
	module Classes
		
		# TODO: Fix default to_s option
		class Money
			attr_reader :total
			alias_method :to_i, :total
			alias_method :to_s, :total
			
			def initialize(total)
				@total = total
			end
			
			def gold
				return (@total / 10000)
			end
			
			def silver
				return (@total % 10000) / 100
			end

			def bronze
				return @total % 100
			end
			
			def +(add)
				return Money.new(self.total + add.total)
			end
			
			def -(add)
				return Money.new(self.total - add.total)
			end
		end
		
	end
end