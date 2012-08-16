class StatusController < ApplicationController
  skip_filter :restrict_ip_address, :authenticate_user!

  def create
    project = Project.find_by_guid(params.delete(:project_id))

    payload = project.webhook_payload
    # NOTE: This throws parse errors, which will appropriately cause this
    # action to 500 if failing, because who cares if an automated process
    # returns a 500 if it submits us with bad data? Don't waste any more cycles
    # caring
    payload.parse_webhook_content request.body.read

    PayloadProcessor.process(project, payload)
	log.method = "webhooks"
    project.save!
    head :ok
  end
end
