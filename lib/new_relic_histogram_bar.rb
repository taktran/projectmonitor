class NewRelicHistogramBar
  def initialize(new_relic_histogram, points_value, index)
    self.new_relic_histogram = new_relic_histogram
    self.points_value = points_value
    self.index = index
  end

  attr_reader :points_value

  delegate :number_of_points_values, :maximum_points_value, :opacity_step, :to => :new_relic_histogram

  def height_percentage
    (points_value.to_f / maximum_points_value * 100).to_i + NewRelicHistogram::ZERO_OFFSET
  end

  def opacity
    (1 - ((number_of_points_values - (index + 1)) * opacity_step)).round(2)
  end

  private

  attr_accessor :new_relic_histogram, :index
  attr_writer :points_value
end
