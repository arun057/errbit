class NotificationServices::NewrelicService < NotificationService
  Label = "NewRelic"
  Fields = [
  	[:api_token, {
  		:placeholder => "Api Key",
  		:label => "NewRelic Api Key"
  	}]
  ]

  def create_notification(problem)
  	# raise problem.inspect
  	NewRelic::Agent.notice_error("#{notification_description problem}", {
  		:uri => "http://#{Errbit::Config.host}/apps/#{problem.app.id.to_s}"
  	  })
  end
end