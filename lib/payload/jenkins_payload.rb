class JenkinsPayload < Payload

  def parse_polled_content(content)
    build_status = [JSON.parse(content)]

    @building = build_status['phase'] == 'STARTED'
    @build_statuses = [OpenStruct.new(
      success: build_status['phase'] == 'SUCCESS',
      build_id: build_status['number'],
      url: build_status['url'],
      published_at: Time.now)]

    true
  end

end
