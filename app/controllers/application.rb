class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '07bbc84302dbb19814b6b7f60c233913'
  
  filter_parameter_logging :password, :password_confirmation
  
  Time::DATE_FORMATS[:raid] = '%Y-%m-%d (%a)'
end
