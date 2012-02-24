class StrainsController < ApplicationController
  # GET /strains
  # GET /strains.json
  def index

    @strains = Strain.overview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @strains }
    end

  end

  # GET /strains/1
  # GET /strains/1.json
  # GET /strains/1.sbol
  def show
    @strain = Strain.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @strain }
      format.sbol do 
        send_data(@strain.to_sbol, 
                  :filename => @strain.filename,
                  :disposition => 'inline', # or 'attachment'
                  :type => 'application/xml')
      end
    end
  end

  # GET /strains/new
  # GET /strains/new.json
  def new
    @strain = Strain.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @strain }
    end
  end

  # GET /strains/1/edit
  def edit
    @strain = Strain.find(params[:id])
  end

  # POST /strains
  # POST /strains.json
  def create
    @strain = Strain.new(params[:strain])

    respond_to do |format|
      if @strain.save
        format.html { redirect_to @strain, :notice => 'Strain was successfully created.' }
        format.json { render :json => @strain, :status => :created, :location => @strain }
      else
        format.html { render :action => "new" }
        format.json { render :json => @strain.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /strains/1
  # PUT /strains/1.json
  def update
    @strain = Strain.find(params[:id])

    respond_to do |format|
      if @strain.update_attributes(params[:strain])
        format.html { redirect_to @strain, :notice => 'Strain was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @strain.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /strains/1
  # DELETE /strains/1.json
  def destroy
    @strain = Strain.find(params[:id])
    @strain.destroy

    respond_to do |format|
      format.html { redirect_to strains_url }
      format.json { head :ok }
    end
  end


  def foo

    @strains = Strain.find(:all)

  end


end


