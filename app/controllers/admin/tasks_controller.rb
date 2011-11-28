class Admin::TasksController < ApplicationController

  # TODO should only be available to admins

  def index
    render :text => "index"
  end


  def reanalyze

  end

  def bar
      ProcessMailer.flowcyte_completed(User.first, PlateLayout.first).deliver
    render :text => 'delivered'
  end

  def foo

    render :text => "module: #{m}"
  end

  def delay
    if !current_user
      render :text => "please log in"
      return
    end

    # deliver mail immediately
    # ProcessMailer.flowcyte_completed(current_user).deliver

    # deliver mail delayed
    ProcessMailer.delay.flowcyte_completed(current_user)

    # delay method
    # current_user.delay.foowriter

    render :text => 'delaying!'
  end

end
