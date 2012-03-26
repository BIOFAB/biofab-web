
class Numeric
  def square
    self * self
  end
end

module Enumerable
 
  #  sum of an array of numbers
  def sum
    return self.inject(0){|acc,i|acc +i}
  end
 
  #  mean of an array of numbers
  def mean
    return self.sum/self.length.to_f
  end
 
  #  variance of an array of numbers
  def variance2
    avg=self.mean
    sum=self.inject(0){|acc,i|acc +(i-avg)**2}
    return(1/self.length.to_f*sum)
  end

  def squares
    self.inject(0){|a,x|x.square+a}
  end
 
  def variance
   self.squares.to_f/self.size - self.mean.square
  end

  #  standard deviation of an array of numbers
  def standard_deviation
    return Math.sqrt(self.variance)
  end
 
end  #  module Enumerable
