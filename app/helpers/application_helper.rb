# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def wowhead_url(wow_id)
    "http://www.wowhead.com/?item=#{wow_id}"
  end
  
  def navtab(link_title, link_path)
    options = ""
    options = {:class => "active"} if link_title.downcase == controller_name
    content_tag(:li, link_to(link_title, link_path), options)
  end
end
