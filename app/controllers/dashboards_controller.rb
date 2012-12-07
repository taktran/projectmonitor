class DashboardsController < ApplicationController
  layout 'dashboard'

  respond_to :html, :only => :index
  respond_to :rss, :only => :builds
  respond_to :json, :only => [:github_status, :index]

  def index
    @tiles_count = (params[:tiles_count].presence || 15).to_i

    aggregate_projects = []
    projects = if aggregate_project_id = params[:aggregate_project_id]
                 AggregateProject.find(aggregate_project_id).projects
               else
                 aggregate_projects = AggregateProject.displayable(params[:tags])
                 Project.standalone
               end
    projects =  projects.displayable(params[:tags])

    tiles = projects.concat(aggregate_projects).sort_by { |p| p.code.downcase }
      .take(@tiles_count)
    @tiles = ProjectDecorator.decorate tiles

    respond_with @tiles
  end

  def builds
    @projects = Project.standalone.with_statuses + AggregateProject.with_statuses
    respond_with @projects
  end

  def github_status
    status = '{"status":"bad"}'
    begin
      status = UrlRetriever.retrieve_content_at('https://status.github.com/status.json')
    rescue Net::HTTPError => e
    end
    respond_with JSON.parse(status)
  end
end
