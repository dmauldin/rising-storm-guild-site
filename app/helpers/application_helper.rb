# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def wowhead_url(wow_id)
    "http://www.wowhead.com/?item=#{wow_id}"
  end
  
  def rank_name_from_id(id)
    return ['Guild Master', 'Officer', 'Organizer', 'Raider', 'Trial', 'Alt', 'Member'][id]
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
  
  # expects an instance of Toon
  def colored_toon_name(toon)
    Rails.cache.fetch("colored_toon_name_#{toon.name}") {
      content_tag(:span, toon.name, :class => toon.job.name.downcase.sub(/ /, "_"))
    }
  end
  
  def inventory_type_name(id)
    return Item::INV_TYPE_HASH[id]
  end
  
  def navtab(link_title, link_path)
    options = ""
    options = {:class => "active"} if link_title.downcase == controller_name
    content_tag(:li, link_to(link_title, link_path), options)
  end
  
  def show_admin_content?
    signed_in_as_admin?
  end
  
  def search_records_summary(search)
    "Displaying #{search.per_page*(search.page-1)+1} to #{search.per_page*(search.page-1)+search.per_page} out of #{search.count}."
  end
end
