class TravisPayload < Payload

  def parse_polled_content(content)
    build_status = Rack::Utils.parse_nested_query(content)['payload'] || ''

    published_at = (finished_at = build_status['finished_at']).present? && Time.parse(finished_at)
    @building = build_status['state'] == 'started'
    @build_statuses = [OpenStruct.new(
      success: build_status['state'] != 'started' && build_status['result'].to_i == 0,
      build_id: build_status['id'],
      published_at: published_at)]

    true
  end

end
