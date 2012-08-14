module StatusFetcher
  class Job < Struct.new(:project)
    def perform
      retrieve_status
      retrieve_velocity

    end

    private

    def retrieve_status
      StatusFetcher.retrieve_status_for(project)
    end

    def retrieve_velocity
      StatusFetcher.retrieve_velocity_for(project)
    end

    def success
      project.set_next_poll
      project.save!
    end

    def error
      #write something to the logs
      project.backoff_time += 1
      project.set_next_poll(project.backoff_time)
      project.save!
    end

  end

  class << self
    def fetch_all
      Project.updateable.each do |project|
        Delayed::Job.enqueue(StatusFetcher::Job.new(project), priority: 1)
      end
    end

    def retrieve_status_for(project)
      ProjectUpdater.update(project)
    end

    def retrieve_velocity_for(project)
      return unless project.tracker_project?

      tracker = TrackerApi.new(project)
      project.current_velocity = tracker.current_velocity
      project.last_ten_velocities = tracker.last_ten_velocities
      project.tracker_online = true
    rescue RestClient::Exception
      project.tracker_online = false
    end
  end
end

