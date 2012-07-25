class JenkinsPayload; end
class JenkinsJsonPayload < Payload
  def building?
    status_content.first["build"]["phase"] == "STARTED"
  end

  private

  def convert_content!(content)
    [Array.wrap(JSON.parse(content.keys.first)).first] 
  rescue JSON::ParserError
    self.processable = false
    self.build_processable = false
    []
  end

  def parse_success(content)
    # TODO: find actual return code for success
    content["build"]["phase"] == "SUCCESS"
  end

  def parse_url(content)
    content["build"]["url"]
  end

  def parse_build_id(content)
    content["build"]["number"]
  end

  def parse_published_at(content)
    Time.now
  end
end

class JenkinsXmlPayload < JenkinsPayload
  def building?
    p_element = build_status_content.xpath("//project[@name=\"#{project.project_name.downcase}\"]")
    return false if p_element.empty?
    p_element.attribute('activity').value == 'building'
  end

  private

  def convert_content!(content)
    if content
      Nokogiri::XML.parse(content.downcase).css('feed entry')
    else
      self.processable = false
      []
    end
  end

  def convert_build_content!(content)
    if content
      Nokogiri::XML.parse(content.downcase)
    else
      self.build_processable = false
    end
  end

  def parse_success(content)
    if (title = content.css('title')).present?
      !!(title.first.content.downcase =~ /success|stable|back to normal/)
    end
  end

  def parse_url(content)
    if link = content.css('link').first
      link.attribute('href').value
    end
  end

  def parse_build_id(content)
    if url = parse_url(content)
      url.split('/').last
    end
  end

  def parse_published_at(content)
    pub_date = Time.parse(content.css('published').first.content)
    (pub_date == Time.at(0) ? Time.now : pub_date).localtime
  end
end
