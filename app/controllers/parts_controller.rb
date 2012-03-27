class PartsController < ApplicationController
  # GET /parts
  # GET /parts.json
  def index
    @parts = Part.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @parts }
    end
  end

  # GET /parts/1
  # GET /parts/1.json
  def show
    @part = Part.find(params[:id], :include => {:annotations => :annotation_type})

    @performance = 0.6 # expression level (optional)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @part }
      format.fasta do 
        send_data(@part.to_fasta, 
                  :filename => "#{@part.biofab_id}.fasta",
                  :disposition => 'inline', # or 'attachment'
                  :type => 'application/fasta')
      end
      format.sbol do 
        data = @part.to_sbol
        if !data
          render :content_type => 'text/plain', :status => 404, :text => "The selected part cannot be converted to SBOL as it has not yet been assigned a unique BIOFAB identifier."
        else
          send_data(data, 
                    :filename => "#{@part.biofab_id}.sbol",
                    :disposition => 'inline', # or 'attachment'
                    :type => 'application/fasta')
        end
      end

      format.json { render :text => @part }
    end
  end

  # GET /parts/new
  # GET /parts/new.json
  def new
    @part = Part.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @part }
    end
  end

  # GET /parts/1/edit
  def edit
    @part = Part.find(params[:id])
  end

  # POST /parts
  # POST /parts.json
  def create
    @part = Part.new(params[:part])

    respond_to do |format|
      if @part.save
        format.html { redirect_to @part, :notice => 'Part was successfully created.' }
        format.json { render :json => @part, :status => :created, :location => @part }
      else
        format.html { render :action => "new" }
        format.json { render :json => @part.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /parts/1
  # PUT /parts/1.json
  def update
    @part = Part.find(params[:id])

    respond_to do |format|
      if @part.update_attributes(params[:part])
        format.html { redirect_to @part, :notice => 'Part was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @part.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /parts/1
  # DELETE /parts/1.json
  def destroy
    @part = Part.find(params[:id])
    @part.destroy

    respond_to do |format|
      format.html { redirect_to parts_url }
      format.json { head :ok }
    end
  end
end
