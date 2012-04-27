module StandardDeviation
  extend self

  def variance(population)
    n = 0
    mean = 0.0
    s = 0.0
    population.each { |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    }
    s / n
  end

  def standard_deviation(population)
    Math.sqrt(variance(population))
  end
end
