class ItemsController < ApplicationController
  def index
    # show item search and statistics
  end
  
  def show
    @item = Item.find_by_wow_id(params[:id])
  end
end
