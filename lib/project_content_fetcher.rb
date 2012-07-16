class ProjectContentFetcher
  attr_accessor :project

  delegate :feed_url, :build_status_url, :auth_username, :auth_password, to: :project

  def initialize(project)
    self.project = project
  end

  def fetch
    if feed_url == build_status_url
      content = fetch_status
      { feed_content: content, build_status_content: content }
    else
      { feed_content: fetch_status, build_status_content: fetch_building_status }
    end
  end

  private

  def fetch_status
    UrlRetriever.retrieve_content_at(feed_url, auth_username, auth_password)
  rescue Net::HTTPError => e
    error = "HTTP Error retrieving status for project '##{project.id}': #{e.message}"
    project.statuses.create(:error => error) unless project.status.error == error
    nil
  end

  def fetch_building_status
    UrlRetriever.retrieve_content_at(build_status_url, auth_username, auth_password)
  rescue Net::HTTPError => e
    project.update_attribute(:building, false)
    nil
  end
end
