class ApplicationController < ActionController::Base
  include Clearance::App::Controllers::ApplicationController
  include HoptoadNotifier::Catcher

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '07bbc84302dbb19814b6b7f60c233913'
  
  filter_parameter_logging :password
  
  Time::DATE_FORMATS[:raid] = '%Y-%m-%d (%a)'
  
  helper_method :signed_in_as_admin?
  
  def signed_in_as_admin?
    signed_in? && current_user.admin?
  end
  
  def users_only
    deny_access("Please Login or Create an Account to Access that Feature.") unless signed_in?
  end
  
  def admin_only
    deny_access("Please Login as an administrator to Access that Feature.") unless signed_in_as_admin?
  end
  
  def deny_access(flash_message = nil, opts = {})
    store_location
    flash[:failure] = flash_message if flash_message
    redirect_to new_session_path #, :status => :unauthorized
  end
end
