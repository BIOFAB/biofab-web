class CharacterizationTypesController < ApplicationController
  # GET /characterization_types
  # GET /characterization_types.json
  def index
    @characterization_types = CharacterizationType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @characterization_types }
    end
  end

  # GET /characterization_types/1
  # GET /characterization_types/1.json
  def show
    @characterization_type = CharacterizationType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @characterization_type }
    end
  end

  # GET /characterization_types/new
  # GET /characterization_types/new.json
  def new
    @characterization_type = CharacterizationType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @characterization_type }
    end
  end

  # GET /characterization_types/1/edit
  def edit
    @characterization_type = CharacterizationType.find(params[:id])
  end

  # POST /characterization_types
  # POST /characterization_types.json
  def create
    @characterization_type = CharacterizationType.new(params[:characterization_type])

    respond_to do |format|
      if @characterization_type.save
        format.html { redirect_to @characterization_type, :notice => 'Characterization type was successfully created.' }
        format.json { render :json => @characterization_type, :status => :created, :location => @characterization_type }
      else
        format.html { render :action => "new" }
        format.json { render :json => @characterization_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /characterization_types/1
  # PUT /characterization_types/1.json
  def update
    @characterization_type = CharacterizationType.find(params[:id])

    respond_to do |format|
      if @characterization_type.update_attributes(params[:characterization_type])
        format.html { redirect_to @characterization_type, :notice => 'Characterization type was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @characterization_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /characterization_types/1
  # DELETE /characterization_types/1.json
  def destroy
    @characterization_type = CharacterizationType.find(params[:id])
    @characterization_type.destroy

    respond_to do |format|
      format.html { redirect_to characterization_types_url }
      format.json { head :ok }
    end
  end
end
