class NoticesController < ApplicationController
  respond_to :xml

  skip_before_filter :authenticate_user!, :only => [:create, :options]

  def create
    # params[:data] if the notice came from a GET request, raw_post if it came via POST
    set_access_control_headers
    notice = App.report_error!(URI.unescape(request.raw_post) || params[:data])
    api_xml = notice.to_xml(:only => false, :methods => [:id]) do |xml|
      xml.url locate_url(notice.id, :host => Errbit::Config.host)
    end
    render :xml => api_xml
  end

  # Redirects a notice to the problem page. Useful when using User Information at Airbrake gem.
  def locate
    problem = Notice.find(params[:id]).problem
    redirect_to app_problem_path(problem.app, problem)
  end

  def options
    if access_allowed?
      set_access_control_headers
      head :ok
    else
      head :forbidden
    end
  end

  private
  def set_access_control_headers 
    headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN']
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = '1000'
    headers['Access-Control-Allow-Headers'] = '*, origin, content-type'
  end


  def access_allowed?
    allowed_sites = [request.env['HTTP_ORIGIN']] #you might query the DB or something, this is just an example
    return allowed_sites.include?(request.env['HTTP_ORIGIN'])
    # return true
  end
end
