class DelayedJob < ActiveRecord::Base

  def self.running
    self.where("locked_at IS NOT NULL")
  end

  def self.queued
    self.where("locked_at IS NULL")
  end
  
  def status
    if !failed_at
      if locked_at
        'running'
      else
        'queued'
      end
    else
      if locked_at
        're-running'
      else
        're-queued'
      end
    end
  end


end
