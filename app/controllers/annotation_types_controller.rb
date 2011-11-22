class AnnotationTypesController < ApplicationController
  # GET /annotation_types
  # GET /annotation_types.json
  def index
    @annotation_types = AnnotationType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @annotation_types }
    end
  end

  # GET /annotation_types/1
  # GET /annotation_types/1.json
  def show
    @annotation_type = AnnotationType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @annotation_type }
    end
  end

  # GET /annotation_types/new
  # GET /annotation_types/new.json
  def new
    @annotation_type = AnnotationType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @annotation_type }
    end
  end

  # GET /annotation_types/1/edit
  def edit
    @annotation_type = AnnotationType.find(params[:id])
  end

  # POST /annotation_types
  # POST /annotation_types.json
  def create
    @annotation_type = AnnotationType.new(params[:annotation_type])

    respond_to do |format|
      if @annotation_type.save
        format.html { redirect_to @annotation_type, :notice => 'Annotation type was successfully created.' }
        format.json { render :json => @annotation_type, :status => :created, :location => @annotation_type }
      else
        format.html { render :action => "new" }
        format.json { render :json => @annotation_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /annotation_types/1
  # PUT /annotation_types/1.json
  def update
    @annotation_type = AnnotationType.find(params[:id])

    respond_to do |format|
      if @annotation_type.update_attributes(params[:annotation_type])
        format.html { redirect_to @annotation_type, :notice => 'Annotation type was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @annotation_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /annotation_types/1
  # DELETE /annotation_types/1.json
  def destroy
    @annotation_type = AnnotationType.find(params[:id])
    @annotation_type.destroy

    respond_to do |format|
      format.html { redirect_to annotation_types_url }
      format.json { head :ok }
    end
  end
end
