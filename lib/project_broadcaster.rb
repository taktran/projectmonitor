module ProjectBroadcaster
  def self.broadcast_update(project)
    if project.persisted?
      # Don't need to look at status - just send full partial
      ac = ProjectsController.new
      project_decorator = ProjectDecorator.new(project)

      channel = if project.is_a?(AggregateProject)
                  "aggregate_project_#{project.id}"
                else
                  "project_#{project.id}"
                end

      message = ac.render_to_string(
        partial: project.to_partial_path,
        locals: {
          aggregate_project: project_decorator,
          project: project_decorator,
          tiles_count: 15
        }
      )

      Pusher[channel].trigger('projectUpdate', message)

      # Broadcast the update to the aggregate project if it exists
      if project.is_a?(Project) && !project.aggregate_project.nil?
        broadcast_update(project.aggregate_project)
      end
    end
  end
end
