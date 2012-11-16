class NewRelicHistogram
  ZERO_OFFSET = 5

  def initialize(response_times)
    self.response_times = response_times
  end

  def each_bar(&block)
    response_times.each_with_index do |point, index|
      yield NewRelicHistogramBar.new(self, point, index)
    end
  end

  def maximum_points_value
    response_times.max
  end

  def number_of_points_values
    response_times.count
  end

  def opacity_step
    minimum_opacity = 0.3
    (1 - minimum_opacity) / number_of_points_values
  end

  private

  attr_accessor :response_times
end
