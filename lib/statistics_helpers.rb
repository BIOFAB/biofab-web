
class StatisticsHelpers

  def self.square(number)
    number*number
  end

  #  sum of an array of numbers
  def self.sum(array)
    return array.inject(0){|acc,i|acc +i}
  end
 
  #  mean of an array of numbers
  def self.mean(array)
    return self.sum(array)/array.length.to_f
  end
 
  #  variance of an array of numbers
  def self.variance2(array)
    avg=self.mean(array)
    sum=array.inject(0){|acc,i|acc +(i-avg)**2}
    return(1/array.length.to_f*sum)
  end

  def self.squares(array)
    array.inject(0){|a,x|self.square(x)+a}
  end
 
  def self.variance(array)
   self.squares(array).to_f/array.size - self.square(self.mean(array))
  end

  #  standard deviation of an array of numbers
  def self.standard_deviation(array)
    return Math.sqrt(self.variance(array))
  end
 

end
