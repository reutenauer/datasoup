# Extension to the Ruby core

class Array
  def average(ndigits = 1)
  (@hits.inject(0) do |sum, hit|
    sum + hit.first
  end * 1.0 / @hits.count)
  end

  def final_score
    (average + 20) / 4
  end
end
