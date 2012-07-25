class StatusController < ApplicationController
  def create
    project = Project.find(params.delete(:project_id))
    payload = project.webhook_payload.new.content(params)
    PayloadProcessor.new(project, payload).process
    head :ok
  end
end
