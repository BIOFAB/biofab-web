class DesignsController < ApplicationController
  layout 'designer' #, :only => [:index]

  # GET /designs
  # GET /designs.json
  def index
    if params['from'] && params['to']
      @designs = Design.in_performance_range(params['from'].to_f, params['to'].to_f)
    else
      @designs = Design.all
    end

    @values_json = @designs.collect {|design| design.performance}.to_json

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @designs }
    end
  end


  def widgets

    if !params['from'] || !params['to']
      render :text => "missing parameters", :status => 404
      return
    end

    @limit = [(params['limit'] || 20).to_i, 50].min
    @offset = (params['offset'] || 0).to_i

    @designs = Design.in_performance_range(params['from'].to_f, params['to'].to_f, @limit, @offset)

    render :partial => 'widgets'
  end


  # GET /designs/1
  # GET /designs/1.json
  def show

    @design = Design.includes({:promoter => {:annotations => :annotation_type}, :fpu => {:annotations => :annotation_type}}).find(params[:id])
    if !@design
      render :text => 'NOT FOUND'
      return
    end

    @promoter = @design.promoter
    @fpu = @design.fpu
    @terminator = nil

    @promoter_performance = 0.6
    @fpu_performance = 0.3
    @performance = 0.5
    @performance_deviation = 0.05
    @reliability = 7

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @design }
    end
  end

  def eou

    @promoter = Part.find(42, :include => {:annotations => :annotation_type})
    @utr = Part.find(420, :include => {:annotations => :annotation_type})
    @terminator = nil

  end

  def flash_test

  end
end
