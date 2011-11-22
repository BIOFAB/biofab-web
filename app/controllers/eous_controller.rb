class EousController < ApplicationController
  # GET /eous
  # GET /eous.json
  def index
    @eous = Eou.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @eous }
    end
  end

  # GET /eous/1
  # GET /eous/1.json
  def show
    @eou = Eou.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @eou }
    end
  end

  # GET /eous/new
  # GET /eous/new.json
  def new
    @eou = Eou.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @eou }
    end
  end

  # GET /eous/1/edit
  def edit
    @eou = Eou.find(params[:id])
  end

  # POST /eous
  # POST /eous.json
  def create
    @eou = Eou.new(params[:eou])

    respond_to do |format|
      if @eou.save
        format.html { redirect_to @eou, :notice => 'Eou was successfully created.' }
        format.json { render :json => @eou, :status => :created, :location => @eou }
      else
        format.html { render :action => "new" }
        format.json { render :json => @eou.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /eous/1
  # PUT /eous/1.json
  def update
    @eou = Eou.find(params[:id])

    respond_to do |format|
      if @eou.update_attributes(params[:eou])
        format.html { redirect_to @eou, :notice => 'Eou was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @eou.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /eous/1
  # DELETE /eous/1.json
  def destroy
    @eou = Eou.find(params[:id])
    @eou.destroy

    respond_to do |format|
      format.html { redirect_to eous_url }
      format.json { head :ok }
    end
  end
end
