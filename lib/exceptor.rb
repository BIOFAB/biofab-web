
module Exceptor

  def self.call_r_func(r, method, *args)
    begin 
      r.source('exceptor.r')
      ret = r.with_error_handling(method, *args)
    rescue Exception => e
      very_random_string = "9pAGbyeZxOMh3Py1tO5YrsrYj7pHyWP5bNRrI5p6Z0MKAPVAoH3pjpUFvy0ewG98"
      method_name_random_string = "pAGbyeZxOMh3Py1"
      r_msg, r_backtrace = e.message.split(very_random_string)
      traces = r_backtrace.split("\n").collect {|line| line.strip.gsub(/^\d:\s/, '')}
      traces = traces[3..(traces.length - 3)]
      traces = traces.collect do |trace|
        trace.gsub(method_name_random_string, 'r_method_that_was_called_from_ruby').strip
      end

      e2 = Exception.new({
        :r_msg => r_msg.split(' : ')[1].strip,
        :r_backtrace => traces
      })
      e2.set_backtrace(e.backtrace)
      raise e2
    end
    return ret
  end

end


