class Payload
  def initialize(project)
    self.project = project
    self.processable = true
    self.build_processable = true
    self.statuses = []
  end

  def each_status
    status_content.each do |content|
      yield ProjectStatus.new(
        success: parse_success(content),
        url: parse_url(content),
        build_id: parse_build_id(content),
        published_at: parse_published_at(content)
      )
    end
  end

  def status_content=(content)
    @status_content = convert_content!(content)
  end

  def build_status_content=(content)
    @build_status_content = convert_build_content!(content)
  end

  # TODO: get rid of me
  def content(content)
    self.status_content = content
    self.build_status_content = content

    self
  end

  def status_is_processable?
    has_status_content? && !!processable
  end

  def build_status_is_processable?
    has_build_status_content? && !!build_processable
  end

  def building?
    raise NotImplementedError
  end

  private

  def has_status_content?
    status_content.present?
  end

  def has_build_status_content?
    build_status_content.present?
  end

  def convert_content!(content)
    content
  end

  def convert_build_content!(content)
    content
  end

  attr_accessor :project, :processable, :build_processable, :statuses
  attr_reader :status_content, :build_status_content
end
