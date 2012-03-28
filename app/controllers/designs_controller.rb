class DesignsController < ApplicationController
  layout 'designer' #, :only => [:index]

  def details

    @design = Design.find(params['id'])

    render :partial => 'details'
  end

  # partial
  def plasmid

    
    render :partial => 'plasmid'
  end

  def index

    @designs = Design.all

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

    from = params['from'].to_f
    to = params['to'].to_f

    if params['promoter_cannot_contain'].blank?
      @designs = Design.in_performance_range(from, to, @limit, @offset)
      @designs_all = Design.all
    else

      seqs = params['promoter_cannot_contain'].split('-')
      vals = []
      sqls = []
      seqs.each do |seq|
        next if seq.blank?
        sqls << "promoter_sequence NOT LIKE ? AND fpu_sequence NOT LIKE ?"
        val = "%#{seq.upcase.gsub(/[^ATGC]+/, '')}%"
        vals << val
        vals << val
      end
      sql = sqls.join(' AND ')
      if sql.blank?
        sql_append = ''
      else
        sql_append = ' AND ' + sql
      end

#      raise (["performance >= ? AND performance <= ?" + sql_append, from, to] + vals).inspect

      @designs = Design.where(["performance >= ? AND performance <= ?" + sql_append, from, to] + vals).includes({:promoter => [:part_performance, {:annotations => :annotation_type}], :fpu => [:part_performance, {:annotations => :annotation_type}]}).limit(@limit).offset(@offset)


      @designs_all = Design.where([sql] + vals)
#      @designs_all = Design.where(["promoter_sequence NOT LIKE ?", subseq])

    end

    # TODO maaan we should probably be rendering the template client side if we're gonna send the data anyway
    # except we're actually doing two separate queries, so maybe not :-/
    output = {
      :html => render_to_string(:partial => 'widgets'),
      :designs => @designs_all ? @designs_all.collect(&:performance) : nil
    }

    render :json => output
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

  def get_plasmid_json

    design = Design.find(params['design_id'])

    render :text => {
      :name => design.plasmid.biofab_id,
      :sequence => design.plasmid.sequence,
      :features => design.plasmid.annotations_for_flash_widgets
    }.to_json

  end

end
