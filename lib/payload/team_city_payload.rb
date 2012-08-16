class TeamCityPayload < Payload

  def parse_polled_content(content)
    build_status = [JSON.parse(content)["build"]]

    published_at = (finished_at = build_status['finished_at']).present? && Time.parse(finished_at)
    @building = build_status['buildResult'] == 'running' && build_status['notifyType'] == 'buildStarted'
    @build_statuses = [OpenStruct.new(
      success: build_status['buildResult'] == 'success',
      build_id: build_status['buildId'],
      published_at: Time.now)]

    true
  end

end
