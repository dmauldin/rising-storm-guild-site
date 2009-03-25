class UsersController < ApplicationController
  include Clearance::App::Controllers::UsersController
  def show
    @user = User.find(params[:id])
  end
end