class HomeController < ApplicationController
  def index
    redirect_to loots_path
  end
end
