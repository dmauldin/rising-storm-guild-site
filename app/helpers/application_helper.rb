# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def wowhead_url(wow_id)
    "http://www.wowhead.com/?item=#{wow_id}"
  end
  
  def formatted_job(job)
    if job
      return content_tag(
        :span,
        job.name,
        :class => job.name.downcase.sub(/ /, "_")
      )
    else
      return "Unknown"
    end
  end
  
  def inventory_type_name(id)
    inv_type_hash = {
      1 => "Head",
      2 => "Neck",
      3 => "Shoulder",
      4 => "Shirt",
      5 => "Chest",
      6 => "Waist",
      7 => "Legs",
      8 => "Feet",
      9 => "Wrist",
      10 => "Hands",
      11 => "Ring",
      12 => "Trinket",
      13 => "One-Hand",
      14 => "Off-Hand",
      15 => "Ranged",
      16 => "Back",
      17 => "Two-Hand",
      21 => "Main-Hand",
      23 => "Held in off-hand",
      26 => "Wand",
      28 => "Ranged",
    }
    return inv_type_hash[id]
  end
  
  def navtab(link_title, link_path)
    options = ""
    options = {:class => "active"} if link_title.downcase == controller_name
    content_tag(:li, link_to(link_title, link_path), options)
  end
end
