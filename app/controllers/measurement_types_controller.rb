class MeasurementTypesController < ApplicationController
  # GET /measurement_types
  # GET /measurement_types.json
  def index
    @measurement_types = MeasurementType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @measurement_types }
    end
  end

  # GET /measurement_types/1
  # GET /measurement_types/1.json
  def show
    @measurement_type = MeasurementType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @measurement_type }
    end
  end

  # GET /measurement_types/new
  # GET /measurement_types/new.json
  def new
    @measurement_type = MeasurementType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @measurement_type }
    end
  end

  # GET /measurement_types/1/edit
  def edit
    @measurement_type = MeasurementType.find(params[:id])
  end

  # POST /measurement_types
  # POST /measurement_types.json
  def create
    @measurement_type = MeasurementType.new(params[:measurement_type])

    respond_to do |format|
      if @measurement_type.save
        format.html { redirect_to @measurement_type, :notice => 'Measurement type was successfully created.' }
        format.json { render :json => @measurement_type, :status => :created, :location => @measurement_type }
      else
        format.html { render :action => "new" }
        format.json { render :json => @measurement_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /measurement_types/1
  # PUT /measurement_types/1.json
  def update
    @measurement_type = MeasurementType.find(params[:id])

    respond_to do |format|
      if @measurement_type.update_attributes(params[:measurement_type])
        format.html { redirect_to @measurement_type, :notice => 'Measurement type was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @measurement_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /measurement_types/1
  # DELETE /measurement_types/1.json
  def destroy
    @measurement_type = MeasurementType.find(params[:id])
    @measurement_type.destroy

    respond_to do |format|
      format.html { redirect_to measurement_types_url }
      format.json { head :ok }
    end
  end
end
