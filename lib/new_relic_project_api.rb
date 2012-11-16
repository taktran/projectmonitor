class NewRelicProjectApi
  def initialize(project)
    @project = project
    @api_key = project.new_relic_api_key
    @account = project.new_relic_account_id
    @app_id = project.new_relic_app_id
  end

  def average_response_time
    headers = {"x-api-key" => @api_key}
    response = UrlRetriever.retrieve_content_at(build_url, nil, nil, true, headers)
    extract_response_times(response)
  end

  private

  def build_url
    "#{base_url}#{@account}/applications/#{@app_id}/data.json?metrics[]=Agent/MetricsReported/count&field=average_response_time&begin=#{begin_time}&end=#{end_time}"
  end

  def base_url
    "https://api.newrelic.com/api/v1/accounts/"
  end

  def begin_time
    15.minutes.ago.to_datetime.to_s
  end

  def end_time
    Time.zone.now.to_datetime.to_s
  end

  def handle_response(response)
    JSON.parse(response) rescue []
  end

  def extract_response_times(response)
    times = handle_response(response)
    return [] if times.is_a?(Hash) && times.key?("error")
    times.map {|response_time| response_time['average_response_time']}
  end
end
