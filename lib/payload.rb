class Payload

  attr_reader :build_statuses, :building

  def initialize
    @build_statuses = []
    @building = false
  end

  def parse_polled_content(content)
    false
  end

  def parse_webhook_content(content)
    parse_polled_content(content)
  end

  def building?
    !!building
  end

end
