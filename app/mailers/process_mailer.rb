class ProcessMailer < ActionMailer::Base

  # Make helpers available for views
  add_template_helper(ApplicationHelper)

  default :from => Settings['admin_email']


  def performance_calculations_completed(user, layout_id)
    @layout_id = layout_id

    if system("which fortune > /dev/null")
      @fortune = `fortune`
    else
      @fortune = nil
    end

    mail(:to => user.email, 
         :subject => "[FabIO] Performance calculations ready!")

  end


  def flowcyte_completed(user, id)
    # TODO settings.yml
    @id = id

    if system("which fortune > /dev/null")
      @fortune = `fortune`
    else
      @fortune = nil
    end

    mail(:to => user.email, 
         :subject => "[FabIO] Flow cytometer analysis results ready!")

  end

  def error(user, e, extra=nil)
    @user = user
    @r_backtrace = nil
    @extra = extra

    if e.message[:r_msg]
      @message = e.message[:r_msg]
      @r_backtrace = e.message[:r_backtrace]
    else
      @message = e.message
    end

    @backtrace = e.backtrace
    
    mail(:to => user.email, 
         :bcc => Settings['admin_email'],
         :subject => "[FabIO] An error occurred")
  end
  
end
