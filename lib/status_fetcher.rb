module StatusFetcher
  class Job < Struct.new(:project)
    def perform
      retrieve_status
      retrieve_velocity
      retrieve_third_party_data

      project.set_next_poll
      project.save!
    end

    private

    def retrieve_status
      StatusFetcher.retrieve_status_for(project)
    end

    def retrieve_velocity
      StatusFetcher.retrieve_velocity_for(project)
    end

    def retrieve_third_party_data
      StatusFetcher.retrieve_new_relic_data_for(project)
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

    def retrieve_new_relic_data_for(project)
      return unless project.new_relic_project?

      new_relic = NewRelicProjectApi.new(project)
      project.new_relic_response_times = new_relic.average_response_time
      project.new_relic_online = true
    rescue RestClient::Exception
      project.new_relic_online = false
    end
  end
end

