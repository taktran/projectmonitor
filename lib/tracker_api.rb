require 'pivotal_tracker'

class TrackerApi
  def initialize(token, project_id)
    @token = token
    @project_id = project_id
    PivotalTracker::Client.token = token
  end

  def delivered_story_count
    project
      .stories
      .all(current_state: "delivered")
        .count
  end

  def previous_iterations_velocities(count)
    PivotalTracker::Iteration.done(project, :offset => count * -1).map do |iteration|
      iteration.stories.inject(0) do |sum, story|
        sum + story.estimate
      end
    end
  end

  private

  def project
    PivotalTracker::Project.find(@project_id)
  end
end
