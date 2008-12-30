# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def wowhead_url(wow_id)
    "http://www.wowhead.com/?item=#{wow_id}"
  end
end
