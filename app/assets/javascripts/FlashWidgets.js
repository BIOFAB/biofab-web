
/*
  Warning: Because the flash widgets call certain functions in the global scope,
           there can only be one instance of each widget on any given page.
           Either this will be fixed in future versions, or more likely,
           all of this will be ported to html/css/javascript.
*/


var FlashWidgets = {

    init: function() {
        this.PlasmidViewer.parent = this;
        this.SequenceViewer.parent = this;
    },

    PlasmidViewer: {
       
        parent: null,
        hide_node_id: 'hidden',
        node_container_id: 'plasmid_viewer_container',
        node_id: 'plasmid_viewer',
        link_to_sequence_viewer: false,
        on_ready: null,
        ready: false,

        show: function(container_id, link_to_sequence_viewer) {
            this.link_to_sequence_viewer = link_to_sequence_viewer;
            if(container_id && $(container_id)) {
                $(container_id).appendChild($(this.node_container_id));
            }
//            Element.removeClassName('flash_widget_hide');
        },

        hide: function() {
            $(this.hide_node_id).appendChild($(this.node_container_id));            
            this.ready = false;
//            Element.addClassName('flash_widget_hide');            
        },

        load_sequence: function(name, sequence, features) {

            if(sequence == '') {
                return null;
            }
            
            if(!$(this.node_id)) {
                return null;
            }
            
            
            var seq_obj = {
                name: name, 
                sequence: sequence,
                features: features || []
            }

            $(this.node_id).load_sequence(seq_obj);

        },

        on_selection: function(from, to) {
            
            if((from < 0) || (to < 0)) {
                console.log('no select (plasmid viewer)');
                return false;
            }
            console.log("plasmid viewer selected from " + from + " to " + to + ".");
            
            if(this.link_to_sequence_viewer) {
                this.parent.SequenceViewer.select(from, to);
            }
        },

        select: function(from, to) {
            $(this.node_id).select(from, to);
        },

        ready_callback: function() {
            this.ready = true;
            if(this.on_ready) {
                this.on_ready();
                this.on_ready = null;
            }
        }
    },

    SequenceViewer: {

        parent: null,
        hide_node_id: 'hidden',
        node_container_id: 'sequence_viewer_container',
        node_id: 'sequence_viewer',
        link_to_plasmid_viewer: false,
        on_ready: null,
        ready: false,

        show: function(container_id, link_to_plasmid_viewer) {
            this.link_to_plasmid_viewer = link_to_plasmid_viewer;
            if(container_id && $(container_id)) {
                $(container_id).appendChild($(this.node_container_id));
            }
//            Element.removeClassName('flash_widget_hide');
        },

        hide: function() {
            $(this.hide_node_id).appendChild($(this.node_container_id));            
            this.ready = false;
//            Element.addClassName('flash_widget_hide');            
        },

        load_sequence: function(name, sequence, features) {

            if(sequence == '') {
                return null;
            }
            
            if(!$(this.node_id)) {
                return null;
            }
            
            //    console.log('Features: ' + item.get('features'))
            
            var seq_obj = {
                name: name, 
                sequence: sequence,
                features: features || []
            }
            
            return $(this.node_id).load_sequence(seq_obj);
       
        },

        on_selection: function(from, to) {
            
            if((from < 0) || (to < 0)) {
                console.log('no select (sequence viewer)');
                return false;
            }
            console.log("sequence viewer selected from " + from + " to " + to + ".");
            
            if(this.link_to_plasmid_viewer) {
                this.parent.PlasmidViewer.select(from, to);
            }
        },

        select: function(from, to) {
            $(this.node_id).select(from, to);
        },
        
        ready_callback: function() {
            this.ready = true;
            if(this.on_ready) {
                this.on_ready();
                this.on_ready = null;
            }
        }

    },

    ready_callback_arguments: [],

    // arguments: name, sequence, features
    show_and_load: function(container_id) {
        var args = Array.prototype.slice.apply(arguments);
        this.ready_callback_arguments = args.slice(1, args.length); // remove container_id from arg list
//        this.ready_callback_arguments = arguments;
        this.PlasmidViewer.on_ready = this.plasmid_viewer_ready.bind(this);
        this.SequenceViewer.on_ready = this.sequence_viewer_ready.bind(this);
        this.PlasmidViewer.show(container_id, true);
        this.SequenceViewer.show(container_id, true);
    },

    show_and_load_obj: function(container_id, obj) {
        this.show_and_load(container_id, obj.name, obj.sequence, obj.features);
    },

    plasmid_viewer_ready: function() {
        this.PlasmidViewer.load_sequence.apply(this.PlasmidViewer, this.ready_callback_arguments);
    },

    sequence_viewer_ready: function() {
        this.SequenceViewer.load_sequence.apply(this.SequenceViewer, this.ready_callback_arguments);
    },

    load: function(name, sequence, features) {
        this.PlasmidViewer.load_sequence(name, sequence, features);
        this.SequenceViewer.load_sequence(name, sequence, features);
    },
    
    hide: function() {
        this.PlasmidViewer.hide();
        this.SequenceViewer.hide();
    }

};

FlashWidgets.init();

// -----------------------
//   BEGIN flash widgets global API handlers  
// -----------------------

function on_plasmid_viewer_selection() {
    return FlashWidgets.PlasmidViewer.on_selection.apply(FlashWidgets.PlasmidViewer, arguments);
}


function on_sequence_viewer_selection() {
    return FlashWidgets.SequenceViewer.on_selection.apply(FlashWidgets.SequenceViewer, arguments);
}

function plasmid_viewer_ready() {
    FlashWidgets.PlasmidViewer.ready_callback.apply(FlashWidgets.PlasmidViewer, arguments);
}

function sequence_viewer_ready() {
    FlashWidgets.SequenceViewer.ready_callback.apply(FlashWidgets.SequenceViewer, arguments);
}

// -----------------------
//   END flash widgets global API handlers
// -----------------------