class TrackerProjectValidator
  class Job < Struct.new(:params)

    def perform
      PivotalTracker::Client.use_ssl = true
      PivotalTracker::Client.token = params[:auth_token]
      PivotalTracker::Project.find(params[:project_id])
    rescue RestClient::Unauthorized
      :unauthorized
    rescue RestClient::ResourceNotFound
      :not_found
    end

    def success(job)

    end
  end
end
