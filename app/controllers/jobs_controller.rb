class JobsController < ApplicationController

  def index

    @running = DelayedJob.running
    @queued = DelayedJob.queued

  end


end
