class CruiseControlPayloadProcessor
  class << self
    def parse_building_status
      building_status = BuildingStatus.new(false)
      if payload && building_payload = payload.last
        document = Nokogiri::XML(building_payload.downcase)
        project_element = document.at_xpath("/projects/project[@name='#{project.project_name.downcase}']")
        building_status.building = project_element && project_element['activity'] == "building"
      end
      building_status
    end

    def parse_project_status feed_content
      document = Nokogiri::XML(feed_content.downcase)
      status = ProjectStatus.new online: false, success: false
      status.success = !!(find(document, 'title').to_s =~ /success/)

      if (pub_date = find(document, 'pubdate')).present?
        pub_date = Time.parse(pub_date.text)
        status.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
      end

      if url = find(document, 'item/link')
        status.url = url.text
      end

      status
    end

    def find(document, path)
      document.css("#{path}") if document
    end
  end
end
