class DelayedJob < ActiveRecord::Base

  def self.running
    self.where("locked_at IS NOT NULL")
  end

  def self.queued
    self.where("locked_at IS NULL")
  end
  

end
