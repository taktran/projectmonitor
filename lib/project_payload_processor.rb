class ProjectPayloadProcessor
  attr_reader :processor, :payload, :project

  def initialize(project, payload)
    @project = project
    @payload = payload
    @processor = project.processor
  end

  def create_status feed_content
    parsed_status = processor.parse_project_status(feed_content)
    parsed_status.online = true
    project.statuses.create(parsed_status.attributes) unless project.status.match?(parsed_status)
  end

  def set_building_status build_status_content
    building_status = processor.parse_building_status(build_status_content)
    project.update_attribute(:building, building_status.building?)
  end

  def perform
    create_status(payload[:feed_content]) if payload[:feed_content].present?
    set_building_status(payload[:build_status_content]) if payload[:build_status_content].present?
  end
end
