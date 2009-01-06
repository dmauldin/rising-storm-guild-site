class ItemsController < ApplicationController
  def index
    # show item search and statistics
  end
  
  def show
    @item = Item.find(params[:id])
  end
end
