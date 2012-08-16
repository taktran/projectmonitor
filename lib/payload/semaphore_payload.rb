class SemaphorePayload < Payload

  def parse_polled_content(content)
    build_status_json = JSON.parse(content)

    @build_statuses = [OpenStruct.new(
      success: build_status_json['result'] == 'passed',
      url: build_status_json['build_url'],
      build_id: build_status_json['build_number'],
      published_at: Time.parse(build_status_json['finished_at']))]

    true
  end

end
