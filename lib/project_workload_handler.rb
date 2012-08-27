class ProjectWorkloadHandler

  attr_reader :project

  def initialize(project)
    @project = project
  end

  def workload_created(workload)
    workload.add_job(:feed_url, project.feed_url)
    workload.add_job(:build_status_url, project.build_status_url)
    workload.add_job(:dependent_build_info_url, project.dependent_build_info_url)
  end

  def workload_complete(workload)
    status_content = workload.recall(:feed_url)
    build_status_content = workload.recall(:build_status_url)
    dependent_content = workload.recall(:dependent_build_info_url)

    update_ci_status(workload, status_content, build_status_content, dependent_content)
  end

  def workload_failed(workload, error)
    project.payload_log_entries.build(error_text: error, method: 'Polling', status: 'failed')
    project.building = project.online = false
    project.save!
  end

private

  def update_ci_status(workload, status_content, build_status_content = nil, dependent_content = nil)
    payload = project.fetch_payload

    payload.status_content = status_content
    payload.build_status_content = build_status_content if project.build_status_url
    payload.dependent_content = dependent_content

    payload_processor = PayloadProcessor.new(project, payload)
    log = payload_processor.process
    log.method = 'Polling'
    log.save!

    project.set_next_poll
    project.online = true
    project.save!

  rescue => e
    project.reload
    project.payload_log_entries.build(error_text: "#{e.class}: #{e.message}", method: 'Polling', status: 'failed')
    project.online = false
    project.save!

  end

end
