# Actual function for MySQL databases only
class InSet < Searchlogic::Condition::Base
  class << self
    def name_for_columns(column)
      super + ["in"]
    end
  end
  
  def to_conditions(value)
    ["#{column_sql} in (?)", value]
  end
end

class ContainsAny < Searchlogic::Condition::Base
  class << self
    def name_for_columns(column)
      super + ["ca"]
    end
        
    attr_accessor :blacklisted_words, :allowed_characters
  end
 
  self.join_arrays_with_or = true
  
  self.blacklisted_words ||= []
  self.blacklisted_words << ('a'..'z').to_a + ["about", "an", "are", "as", "at", "be", "by", "com", "de", "en", "for", "from", "how", "in", "is", "it", "la", "of", "on", "or", "that", "the", "the", "this", "to", "und", "was", "what", "when", "where", "who", "will", "with", "www"] # from ranks.nl 
  self.allowed_characters ||= ""
  self.allowed_characters += 'àáâãäåßéèêëìíîïñòóôõöùúûüýÿ\-_\.@'
  
  # You can return an array or a string. NOT a hash, because all of these conditions
  # need to eventually get merged together. The array or string can be anything you would put in
  # the :conditions option for ActiveRecord::Base.find(). Also notice the column_sql variable. This is essentail
  # for applying modifiers and should be used in your conditions wherever you want the column.
  def to_conditions(value)
    strs = []
    subs = []
    
    search_parts = value.gsub(/,/, " ").split(/ /)
    replace_non_alnum_characters!(search_parts)
    search_parts.uniq!
    remove_blacklisted_words!(search_parts)
    return if search_parts.blank?
    
    search_parts.each do |search_part|
      strs << "#{column_sql} #{like_condition_name} ?"
      subs << "%#{search_part}%"
    end
    [strs.join(" OR "), *subs]
  end
  
  private
    def replace_non_alnum_characters!(search_parts)
      search_parts.each do |word|
        word.downcase!
        word.gsub!(/[^[:alnum:]#{self.class.allowed_characters}]/, '')
      end
    end
    
    def remove_blacklisted_words!(search_parts)
      search_parts.delete_if { |word| word.blank? || self.class.blacklisted_words.include?(word.downcase) }
    end
end
 
Searchlogic::Conditions::Base.register_condition(ContainsAny)
Searchlogic::Conditions::Base.register_condition(InSet)
