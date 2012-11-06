class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :set_time_zone
  before_filter :preflight_check
  after_filter :set_access_control

  # Devise override - After login, if there is only one app,
  # redirect to that app's path instead of the root path (apps#index).
  def stored_location_for(resource)
    location = super || root_path
    (location == root_path && current_user.apps.count == 1) ? app_path(current_user.apps.first) : location
  end

  rescue_from ActionController::RedirectBackError, :with => :redirect_to_root


protected


  def require_admin!
    redirect_to_root unless user_signed_in? && current_user.admin?
  end

  def redirect_to_root
    redirect_to(root_path)
  end

  def set_time_zone
    Time.zone = current_user.time_zone if user_signed_in?
  end

  def set_access_control
    headers["Access-Control-Allow-Origin"] = "*"
    headers['Access-Control-Request-Method'] = 'POST, GET, OPTIONS'
  end

  def preflight_check
    if @request.method == 'OPTIONS'
      # headers["Access-Control-Allow-Origin"] = "*"
      headers['Access-Control-Allow-Origin'] = "*"
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = "*"
      headers['Access-Control-Max-Age'] = 60 * 60 * 60 * 60
      render :text => '', :content_type => 'text/plain'
    end
  end

end
