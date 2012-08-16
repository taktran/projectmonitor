module PayloadProcessor

  def self.process(project, payload)
    payload.build_statuses.each do |build_status|
      status = ProjectStatus.new(
        success: build_status.success,
        url: build_status.url,
        build_id: build_status.build_id,
        published_at: build_status.published_at)

      next if project.has_status?(status)

      project.statuses.push status
    end

    project.building = payload.building?
  end

end
