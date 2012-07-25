class TeamCityChainedProject < TeamCityRestProject
  include TeamCityProjectWithChildren

  def fetch_payload
    TeamCityChainedXmlPayload
  end

  def webhook_payload
    TeamCityChainedXmlPayload
  end

  private

  def self.project_attribute_prefix
    'team_city_rest'
  end
end
