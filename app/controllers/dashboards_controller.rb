class DashboardsController < ApplicationController
  layout 'dashboard'

  respond_to :html, :only => [:index, :styleguide]
  respond_to :rss, :only => :builds
  respond_to :json, :only => [:github_status, :heroku_status, :rubygems_status, :index]

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
    status = nil
    begin
      status = UrlRetriever.retrieve_content_at('https://status.github.com/status.json')
    rescue
      status = '{"status":"unreachable"}'
    end
    respond_with JSON.parse(status)
  end

  def heroku_status
    status = nil
    begin
      status = UrlRetriever.retrieve_content_at('https://status.heroku.com/api/v3/current-status')
    rescue
      status = '{"status":"unreachable"}'
    end
    respond_with JSON.parse(status)
  end

  def rubygems_status
    status = {}

    begin
      doc = Nokogiri::HTML(UrlRetriever.retrieve_content_at('http://status.rubygems.org/'))
      page_status = doc.css('.services td.status span')

      if page_status.any?
        status[:status] =
          if page_status.last.attributes["class"].value.split(' ').include?("status-up")
            "good"
          else
            "bad"
          end
      else
        status[:status] = 'page broken'
      end

    rescue Nokogiri::SyntaxError => e
      status[:status] = 'page broken'
    rescue
      status[:status] = 'unreachable'
    end

    respond_with status
  end

  def styleguide
  end
end
