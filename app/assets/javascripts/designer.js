
var Designer = {

    results_per_query: 20, // how many results to fetch per query
    results_displayed: 0, // how many results are currently displayed
    eou_list_id: 'eou_list',

    constrain_from: null,
    constrain_to: null,

    constraint_slider_container_id: 'dynamic_slider',
    constraint_slider: null,

    init: function(data) {

        ConstraintSlider.init();

        this.constraint_slider = ConstraintSlider.create(this.constraint_slider_container_id, {
          data: data,
          bin_count: 25,
          histogram_max_height: 40,
          y_axis_max: 'dynamic', // Can also be 'dynamic'. If you specify this, then you _must_not_ have any bins with more entries than y_axis_max. If you do, the widget will exceed histogram_max_height.
          horizontal_lines: true,
          log_scale: true
        });

        this.constraint_slider.on_change = this.retrieve_results.bind(this);

        this.boxed_spinner_template = doT.template($('boxed_spinner_template').text, null, null);

        this.list.init(this);
        StrainDetails.init();
    },

    constrain: function() {
        var disallowed_seqs = $('seq_must_not_contain').value.split(/\n/);
        var i;
        for(i=0; i < disallowed_seqs.length; i++) {
            disallowed_seqs[i] = disallowed_seqs[i].toUpperCase().replace(/[^GATC]/, '');
        }
        $('seq_must_not_contain').value = disallowed_seqs.join("\n");

        console.log(disallowed_seqs);

        this.retrieve_results(null, null, disallowed_seqs.join('-'));
    },

    retrieve_results: function(from, to, promoter_cannot_contain) {

        $(this.eou_list_id).innerHTML = this.boxed_spinner_template({message: "Retrieving results."});

        this.constrain_from = from || this.constrain_from;
        this.constrain_to = to || this.constrain_to;

        if(promoter_cannot_contain) {
            this.promoter_cannot_contain = promoter_cannot_contain;
        }

        console.log('getting first: ' + from + ' - ' + to);
        
        new Ajax.Request('/design_widgets', {
            method: 'get',
            parameters: {
                from: this.constrain_from,
                to: this.constrain_to,
                offset: 0,
                promoter_cannot_contain: this.promoter_cannot_contain,
                limit: this.results_per_query
            },
            onSuccess: this.got_results.bindAsEventListener(this)
        });
    },

    got_results: function(transport) {
        var data = transport.responseText.evalJSON(true);

        // update the constraint-slider's constrained histogram
        // TODO figure out how only to run if it has changed
        if(data.designs) {
            this.constraint_slider.set_externally_filtered_data(data.designs); 
        }

        $(this.eou_list_id).innerHTML = data.html;
        this.results_displayed = this.results_per_query;
        this.list.on_new_results();
    },
    
    retrieve_more_results: function(callback_func) {
        console.log('getting more: ' + this.constrain_from + ' - ' + this.constrain_to);

        new Ajax.Request('/design_widgets', {
            method: 'get',
            parameters: {
                from: this.constrain_from,
                to: this.constrain_to,
                offset: this.results_displayed,
                limit: this.results_per_query,
                promoter_cannot_contain: this.promoter_cannot_contain,
                
            },
            onSuccess: callback_func.bindAsEventListener(this)
        });
    },

    got_more_results: function(transport) {

        // First remove the existing spinner
        var spinners = $(this.eou_list_id).select('.spinner_container');
        var i;
        for(i=0; i < spinners.length; i++) {
            Element.remove(spinners[i]);
        }

        // Then add  the new results (that includes a spinner at the end)
        var data = transport.responseText.evalJSON(true);
        $(this.eou_list_id).innerHTML += data.html;
        this.results_displayed += this.results_per_query;

    },


    list: {

        scroll_query_locked: false, // set to true while query in progress

        update_scroll_query_lock: function() {
            // Unlock "retrieve more"-functionality if there isn't a "all results shown" element
            if(!$('all_results_shown')) {
                this.scroll_query_locked = false;
            } else {
                this.scroll_query_locked = true;
            }
        },

        init: function(parent) {
            this.parent = parent;
            window.onscroll = this.on_scroll.bindAsEventListener(this);
        },

        on_scroll: function(e) {
            var scroll_height = document.viewport.getScrollOffsets().top;
            var body_height = Element.getDimensions(document.body).height;
            var viewport_height = document.viewport.getDimensions().height;
            var total_scroll_height = scroll_height + viewport_height;

            if(body_height - total_scroll_height < 100) {
                if(this.scroll_query_locked) {
                    return false;
                }
                this.scroll_query_locked = true;
                this.parent.retrieve_more_results(this.on_results_received.bindAsEventListener(this));
            }
        },

        on_results_received: function(transport) {
            this.parent.got_more_results(transport);
            this.update_scroll_query_lock();
        },

        // scroll to top of list and hide details
        // run when constraints are modified
        on_new_results: function() {
            this.update_scroll_query_lock();
            var scroll_x = document.viewport.getScrollOffsets().left;
            window.scrollTo(scroll_x, 0);
            StrainDetails.hide(); // TODO StrainDetails should be a sub-object of Designer
        }

    },



}


var StrainDetails = {

    now_showing: null,
    now_showing_id: null,

    init: function() {

        this.spinner_template = doT.template($('spinner_template').text, null, null);

    },

    toggle: function(node) {
        if(this.now_showing == node) {
            this.hide();
        } else {
            this.show(node);
        }
    },
        

    show: function(node) {
        this.hide();
        this.now_showing = node;

        $('constraints_panel').style.display = 'none';
        $('details_panel').style.display = 'block';        

        var nodes = Element.select(node, '.external_interface');
        if(nodes.length < 1) {
            return false;
        }
        nodes[0].style.display = 'block';

        Element.addClassName(nodes[0], 'selected_bg');
        Element.addClassName('right_panel', 'selected_bg');
        Element.addClassName(node, 'selected_bg');

        var nodes = Element.select(node, '.id');
        if(nodes.length < 1) {
            return false;
        }
        var id = nodes[0].innerHTML;

        this.now_showing_id = id;

        // Show "loading" spinner
        $('details_container').innerHTML = this.spinner_template({message: "Fetching details."});

        new Ajax.Request('/design_details', {
            method: 'get',
            parameters: {
                id: id
            },
            onSuccess: this.details_callback.bindAsEventListener(this)
        });
        
        return false;
    },

    // show details in right-hand panel
    details_callback: function(transport) {
        $('details_container').innerHTML = transport.responseText;
    },

    hide: function() {
        this.now_showing = null;
        $('constraints_panel').style.display = 'block';
        $('details_panel').style.display = 'none';
        $('details_container').innerHTML = '';

        Element.removeClassName('right_panel', 'selected_bg');

        var nodes = $$('.eou_widget');
        var i, ext_nodes;
        for(i=0; i < nodes.length; i++) {
            Element.removeClassName(nodes[i], 'selected_bg');

            ext_nodes = Element.select(nodes[i], '.external_interface');
            if(ext_nodes.length < 1) {
                continue;
            }
            ext_nodes[0].style.display = 'none';
            Element.removeClassName(ext_nodes[0], 'selected_bg');

        }
        return false;
    },


    show_plasmid: function(design_id) {
        var loading_html = this.spinner_template({message: "Fetching annotated plasmid sequence."});

        Overlay.show_html(loading_html);

        new Ajax.Request('/designs/get_plasmid_json', {
            method: 'get',
            parameters: {
                design_id: design_id
            },
            onSuccess: this.show_plasmid_callback.bindAsEventListener(this)
        });        

    },

    show_plasmid_callback: function(transport) {

        var obj = transport.responseText.evalJSON(true);

        // TODO kinda hackish
        var html = "<h3>Plasmid sequence for "+obj.name+"</h3><div id='flash_widgets_container'></div>";

        Overlay.show_html(html, this.overlay_hide_callback.bind(this));

        FlashWidgets.show_and_load_obj('flash_widgets_container', obj);

    },

    overlay_hide_callback: function() {
        FlashWidgets.hide();
    }
} // end StrainDetails




