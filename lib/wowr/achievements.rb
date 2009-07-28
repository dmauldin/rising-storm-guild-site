module Wowr
  module Classes
    class CharacterAchievementsInfo
      attr_reader :latest_achievements, :categories
      
      def initialize elem, api
        @api = api
        @latest_achievements = Array.new
        @categories = Array.new
        
        achievements = elem%'achievements'
        summary = achievements%'summary'
        
        # Get list of latest achievements
        summary.search('achievement').each do |achievement|
          @latest_achievements << CompletedAchievement.new(achievement)
        end
        
        # Get the infos about categories completion
        # They are ordered in same order as categories below
        categories_completion = summary.search('category/c')

        # Get the list of rootCategories
        i = 0
        achievements.search('rootCategories/category').each do |category|
          elem = Hash.new
          type = AchievementsCategoryDetails
          elem['id'] = category['id']
          elem['name'] = category['name']
          completion = categories_completion[i]
          elem['earned'] = completion['earned']
          
          # If we have more informations
          if completion['total']
            type = AchievementsCategoryDetailsWithPoints
            elem['total'] = completion['total']
            elem['totalPoints'] = completion['totalPoints']
            elem['earnedPoints'] = completion['earnedPoints']
          end
          new_cat = type.new(elem)
          
          # Add subcategories
          category.search('category').each do |subcategory|
            subcat = AchievementsCategory.new subcategory
            new_cat.add_subcategory subcat
          end
          
          @categories << new_cat
          i = i+1
        end
      end
    end 
    
    class Achievement
      attr_reader :desc, :title, :category_id, :icon, :id, :points, :reward
      def initialize achievement
        @desc = achievement['desc']
        @category_id = achievement['categoryId'].to_i
        @icon = achievement['icon']
        @id = achievement['id'].to_i
        
        if achievement['points']
          @points = achievement['points'].to_i
        else
          @points = nil
        end

        if achievement['reward']
          @reward = achievement['reward']
        else
          @reward = nil
        end

        @title = achievement['title']
      end
    end
    
    class CompletedAchievement < Achievement
      attr_reader :date_completed
      def initialize achievement
        super(achievement)
        @date_completed = achievement['dateCompleted']
        begin
          @date_completed   = achievement[:dateCompleted] == "" ? nil : DateTime.parse(achievement[:dateCompleted])
        rescue
          @date_completed   = achievement[:dateCompleted] == "" ? nil : achievement[:dateCompleted]
        end
      end
    end
    
    class AchievementsCategory
      attr_reader :name
      attr_reader :subcategories
      attr_reader :id
      attr_writer :parent
      def initialize category
        @name = category['name']
        @id = category['id'].to_i if category['id']
        @subcategories = Array.new
      end
      
      def add_subcategory category
        @subcategories << category
        category.parent = self
      end
    end
    
    class AchievementsCategoryDetails < AchievementsCategory
      attr_reader :earned
      def initialize category
        super(category)
        @earned = category['earned'].to_i
      end
    end
    
    class AchievementsCategoryDetailsWithPoints < AchievementsCategoryDetails
      attr_reader :earned_points, :total, :total_points
      def initialize category
        super(category)
        @earned_points = category['earnedPoints'].to_i
        @total = category['total'].to_i
        @total_points = category['totalPoints'].to_i
      end
    end

    class AchievementsList
      attr_reader :achievements
      def initialize elem, api
        @api = api
        @achievements = Array.new
        elem.search('achievement').each do |achievement|
          if achievement['dateCompleted']
            new_achievement = CompletedAchievement.new(achievement)
          else
            new_achievement = Achievement.new(achievement)
          end
          @achievements << new_achievement

        end
      end
    end
  end
end
