
var Designer = {

    results_per_query: 20, // how many results to fetch per query
    results_displayed: 0, // how many results are currently displayed
    eou_list_id: 'eou_list',

    constrain_from: null,
    constrain_to: null,

    init: function() {

        this.spinner_template = doT.template($('spinner_pseudo_widget').text, null, null);

        this.list.init(this);
    },

    retrieve_results: function(from, to) {

        $(this.eou_list_id).innerHTML = this.spinner_template();

        this.constrain_from = from;
        this.constrain_to = to;

        console.log('getting first: ' + from + ' - ' + to);
        
        new Ajax.Request('/design_widgets', {
            method: 'get',
            parameters: {
                from: from,
                to: to,
                offset: 0,
                limit: this.results_per_query
            },
            onSuccess: this.got_results.bindAsEventListener(this)
        });
    },

    got_results: function(transport) {
        $(this.eou_list_id).innerHTML = transport.responseText;
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
                limit: this.results_per_query
                
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
        $(this.eou_list_id).innerHTML += transport.responseText;
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

    overlay: {

        init: function() { return false },

        show_partial: function(url) {
            // TODO not implemented
            this.show();
        },

        show_html: function(html) {
            $('overlay_content').innerHTML = html;
            this.show();
        },

        show: function() {
            $('overlay').style.display = 'block';

            Event.observe($('overlay_grayout'), 'transitionend', this.shown);
            Event.observe($('overlay_grayout'), 'webkitTransitionEnd', this.shown); // webkit compatibility

            // bug-workaround for firefox 10.0.2 (possibly others)
            setTimeout(this.show2, 10);
        },

        show2: function() {
            $('overlay_grayout').style.opacity = 0.3;
            $('overlay_box').style.opacity = 1.0;
        },

        // called when fade-in complete
        shown: function(e) {
            Event.stopObserving($('overlay_grayout'), 'transitionend', this.shown);
            Event.stopObserving($('overlay_grayout'), 'webkitTransitionEnd', this.shown); // webkit compatibility
        },

        hide: function() {
            Event.observe($('overlay_grayout'), 'transitionend', this.hidden);
            Event.observe($('overlay_grayout'), 'webkitTransitionEnd', this.hidden); // webkit compatibility

            $('overlay_grayout').style.opacity = 0;
            $('overlay_box').style.opacity = 0;
        },

        // called when fade-out completed
        hidden: function(e) {
            Event.stopObserving($('overlay_grayout'), 'transitionend', this.hidden);
            Event.stopObserving($('overlay_grayout'), 'webkitTransitionEnd', this.hidden); // webkit compatibility
            $('overlay').style.display = 'none';
        }

    }


}


var StrainDetails = {

    now_showing: null,

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

        $('details_container').innerHTML = 'details for ' + id;
        
        return false;
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
    }

}


// -----------------------
//   BEGIN flash widgets API handlers
// -----------------------

function show_plasmid(biofab_id, sequence, features) {
    if(sequence == '') {
        return null;
    }

    if(!$('plasmid_viewer') || !$('sequence_viewer')) {
        return null;
    }

//    console.log('Features: ' + item.get('features'))

    var seq_obj = {
        name: biofab_id, 
        sequence: sequence,
        features: []
    }

    $('plasmid_viewer').load_sequence(seq_obj);
    $('sequence_viewer').load_sequence(seq_obj);

    return true;
}


function on_plasmid_viewer_selection(from, to) {
    if((from < 0) || (to < 0)) {
        console.log('no select (plasmid viewer)');
        return false;
    }
    console.log("plasmid viewer selected from " + from + " to " + to + ".");
    
    do_sequence_select(from, to);
}

function on_sequence_viewer_selection(from, to) {
    if((from < 0) || (to < 0)) {
        console.log('no select (plasmid viewer)');
        return false;
    }
    console.log("sequence viewer selected from " + from + " to " + to + ".");
   
    do_plasmid_select(from, to);
}


function do_plasmid_select(from, to) {
    $('plasmid_viewer').select(from, to);
}

function do_sequence_select(from, to) {
    $('sequence_viewer').select(from, to);
}

// -----------------------
//   END flash widgets API handlers
// -----------------------