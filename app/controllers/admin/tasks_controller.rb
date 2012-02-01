class Admin::TasksController < ApplicationController

  # TODO should only be available to admins

  def index

  end


  def remove_old_plates
    render :text => 'disabled'
    return
    
    older_than = '2012-01-01'

    plates = Plate.where(["created_at < ?", older_than])

    plates.each do |plate|
      plate.destroy
    end

    render :text => "removed #{plates.length} plates"

  end

  def deorphanize
    # has no orphans:
    #  parts
    #  strains (though it would be nice to list the ones that don't have a project)
   

    # has orphans:
    #  data_files (if no plate_wells are associated)
    #  plate_wells (if no plate is associated (or coming soon, if no replicate is associated))
    #  plate_layout_well (if no plate_layout is associated)
    #  characterization (if no replicate)
    # 

    # eou will just be cleaned out

    Plate.destroy_orphans
    PlateWell.destroy_orphans
    DataFile.destroy_orphans
    DataFile.delete_lost_files

  end

  def eta
    num_jobs = DelayedJob.where("failed_at is NULL").length
    
    time_per_job = 20 # in minutes

    hours = (num_jobs * time_per_job) / 60
    minutes = (num_jobs * time_per_job) % 60

    render :text => "ETA is #{hours} hours and #{minutes} minutes (very rough estimate)"
  end


  # re-analyze and re-calculate performances for all plate layouts in the system
  # this is going to take a while and one email will be received for each plate_layout
  # whether it completes or fails
  def re_analyze_all
    plate_layouts = PlateLayout.all
    plate_layouts.each do |plate_layout|
      next if plate_layout.plates.length == 0 # don't attempt to re-analyze non-existant plates
      PlateLayout.delay.re_analyze_plates(plate_layout, current_user)
    end

    flash[:notice] = "The flow cytometer data is being re-analyzed. You will receive an email at #{current_user.email} when it is complete. When the analysis completes, the new plates will appear under the \"Plates using this layout\" section"

    redirect_to :action => 'index'
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
