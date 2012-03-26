
var Histogram = {

    histograms: [],

    init: function(params) {

        var compile_time_params = Object.extend({

        }, params || {});

        if(!$('histogram_template')) {
            return null;
        }

        this.template = doT.template($('histogram_template').text, undefined, compile_time_params);
    },

    create: function(container_id, params) {
     
        var hist = new this.histogram_class(this, container_id, params);

        if(!hist) {
            return null;
        }

        this.histograms.push(hist);
        return hist;
    },


    destroy: function(hist) {

        var i;
        for(i=0; i < this.histograms.length; i++) {
            if(this.histograms[i] == hist) {
                this.histograms.splice(i, 1);
                return true;
            }
        }
        return false;
    },

    histogram_class: function(parent, container_id, params) {

        this.parent = parent;
        this.unique = Math.floor(Math.random() * 100000000);
        this.changed = false;
        
        if(!$(container_id)) {
            return null;
        }

        this.container_id = container_id;
        this.params = Object.extend({
            per_bar_params: null, // an array of data to be associated with each bar (optional)
            data_is_bar_heights: false, // if true, data is the bin heights, not the raw data
            log_scale: false,
            histogram_max_height: 'inherit', // 'inherit' means expand to fill containing node (can also be a number)
            errors: [], // an array of the error bar sizes
            bar_labels: [], // optional 45 degree text-labels for each bar
            bar_count: 10,
            bar_spacing: 5,
            total_histogram_id: 'total_histogram_'+this.unique,
            constrained_histogram_id: 'constrained_histogram_'+this.unique,
            node_id: 'histogram_'+this.unique
        }, params || {});

        if(this.params.data_is_bar_heights) {
            this.params.bar_count = this.params.data.length;
        }

        var result = this.parent.template(this.params);
        if(result == '') {
            console.log("Error: Histogram is missing doT template");
            return null;
        }

        $(container_id).innerHTML = result;

        var widget = $$('#'+this.container_id + ' .histogram')[0];
        if(!widget) {
            console.log("Error: Histogram could not find its html node");
            return null;
        }

        this.widget_dimensions = Element.getDimensions(widget);

        if(this.params.histogram_max_height == 'inherit') {
            this.params.histogram_max_height = this.widget_dimensions.height;
        }

        this.nilfunc = function(from, to) {
            return false;
        }

        this.on_change = this.nilfunc;

        // TODO put the above in an init function


        this.get_data_range = function(data) {
            
            var min = Number.MAX_VALUE;
            var max = Number.MIN_VALUE;
            for(i=0; i < data.length; i++) {
                if(data[i] < min) {
                    min = data[i];
                }
                if(data[i] > max) {
                    max = data[i];
                }
            }

            return [min, max];
        };


        this.make_histogram_bars = function() {
            if(this.params.data_is_bar_heights) {
                this.bars = this.params.data;
            } else {
                var i;
                this.bars = [];
                for(i=0; i < this.bins.length; i++) {
                    this.bars.push(this.bins[i].length);
                }
            }
            return this.bars;
        },

        this.make_histogram_bins = function(data, bar_count, existing_bins) {

            // if we don't have to handle the bins
            if(this.params.data_is_bin_heights) {
                return null;
            }

            var i;
            var minmax = this.get_data_range(data); // re-calculate data range
            var min = minmax[0];
            var max = minmax[1];

            var bin_size = (max - min) / bar_count;

            // create bins
            var bins = [];
            for(i=0; i < bar_count; i++) {

                if(existing_bins) {
                    bins.push({
                        from: existing_bins[i].from,
                        to: existing_bins[i].to,
                        data: []
                    }); 
                } else {
                    bins.push({
                        from: min + bin_size * i,
                        to: min + bin_size * (i+1),
                        data: []
                    }); 
                }

                // expand last bin up to above the max value
                if(i == (bar_count - 1)) {
                    bins[bins.length - 1].to = max + 1;
                }
            }

            // fill bins with data
            var j;
            for(i=0; i < data.length; i++) {
                for(j=0; j < bins.length; j++) {
                    if((data[i] >= bins[j].from) && (data[i] < bins[j].to)) {
                        bins[j].data.push(data[i]);
                    }
                }
            }

            // TODO remove debug code
/*
            var in_each_bin = [];
            for(i=0; i < bins.length; i++) {
                in_each_bin.push(bins[i].data.length);
            }

            console.log('in each bin: ' + in_each_bin);
*/
            return bins;
        };


        this.init_histogram = function(container_id) {

            if(!this.bars || (this.bars.length == 0)) {
                return null;
            }

            this.bar_nodes = [];
            
            this.widget_width = $(this.params.node_id).getDimensions().width;

            var per_bar = Math.floor(this.widget_width / this.bars.length);

            this.histogram_bar_width = per_bar - this.params.bar_spacing;
            var histogram_left_offset = Math.floor(this.widget_width - this.histogram_bar_width * this.bars.length - this.params.bar_spacing * (this.bars.length - 1));

            var i;
            var pixels_per_data_entries = null;

            // set the normalization factor
            if(this.params.y_axis_max == 'dynamic') { // normalize based on a specified value
                var y_axis_max = 0;
                for(i=0; i < this.bars.length; i++) {
                    if(this.bars[i] > y_axis_max) {
                        y_axis_max = this.bars[i];
                    }
                }
                this.params.y_axis_max = y_axis_max;
            }
            if(this.params.log_scale) {
                pixels_per_data_entry = this.params.histogram_max_height / this.log(this.params.y_axis_max);
            } else {
                pixels_per_data_entry = this.params.histogram_max_height / this.params.y_axis_max;
            }

            // center the histogram
            $(this.params.total_histogram_id).style.left = histogram_left_offset / 2 + 'px';

            // append the nodes
            var node;
            for(i=0; i < this.bars.length; i++) {
                if(this.params.log_scale) {
                    height = Math.round(pixels_per_data_entry * this.log(this.bars[i]));
                } else {
                    height = Math.round(pixels_per_data_entry * this.bars[i]);
                }
                // Set error size for error bar if available
                var error_size = null;
                if(this.params.errors.length > i) {
                    if(this.params.log_scale) {
                        error_size = Math.round(pixels_per_data_entry * this.log(this.params.errors[i]));
                    } else {
                        error_size = Math.round(pixels_per_data_entry * this.params.errors[i]);
                    }
                }
                node = this.make_histogram_bar(i, this.histogram_bar_width, height, error_size);
                node.style.left = (i * this.histogram_bar_width) + (i * this.params.bar_spacing) + 'px';
                this.bar_nodes.push(node);
                $(container_id).appendChild(node);
            }
        };

        this.nullfunc = function() {
            return false;
        };


        this.get_actual_target = function(node) {
            if(node.histogram_index === undefined) {
                if(node.parentNode) {
                    return this.get_actual_target(node.parentNode);
                } else {
                    return null;
                }
            }
            return node;
        };

        this.call_callback_for_node = function(node, callback, from_simulated_event) {
            var i = node.histogram_index;
            var per_bar_param = null;
            if(this.params.per_bar_params && this.params.per_bar_params[i]) {
                per_bar_param = this.params.per_bar_params[i]; 
            }
            if(this.params.data_is_bar_heights) {
                // bar_node, bar_index, value, error, label
                return callback(node, i, from_simulated_event, this.bars[i], this.params.errors[i], this.params.bar_labels[i], per_bar_param);
            } else {
                // bar_node, bin_index, bin_from, bin_to, data, error, label
                return callback(node, i, from_simulated_event, this.bins[i].from, this.bins[i].to, this.bins[i].data, this.params.errors[i], this.params.bar_labels[i], per_bar_param);
            }
        };

        this.on_bar_mouseover = function(e) {
            this.handle_callback(e.target, this.params.on_mouseover, 'hover');
        };
        this.simulate_mouseover = function(bar_index) {
            if(!this.bar_nodes[bar_index]) {
                return false;
            }
            this.handle_callback(this.bar_nodes[bar_index], this.params.on_mouseover, 'hover', false, true);
        };

        this.on_bar_mouseout = function(e) {
            this.handle_callback(e.target, this.params.on_mouseout, 'hover', true);
        };
        this.simulate_mouseout = function(bar_index) {
            if(!this.bar_nodes[bar_index]) {
                return false;
            }
            this.handle_callback(this.bar_nodes[bar_index], this.params.on_mouseout, 'hover', true, true);
        };


        this.on_bar_click = function(e) {
            this.handle_callback(e.target, this.params.on_click, 'active');
        };
        this.simulate_click = function(bar_index) {
            if(!this.bar_nodes[bar_index]) {
                return false;
            }
            this.handle_callback(this.bar_nodes[bar_index], this.params.on_click, 'active', false, true);
        };

        this.handle_callback = function(target, callback, class_name, no_class_set, from_simulated_event) {
            var actual_target = this.get_actual_target(target);
            if(!actual_target) {
                return false;
            }
            if(callback) {
                var retval = this.call_callback_for_node(actual_target, callback, from_simulated_event);
                if(retval) {
                    if(no_class_set) {
                        actual_target = null;
                    }
                    this.bar_set_class(actual_target, class_name, no_class_set);
                }
            }            
        };

        // Set a hover or active class for only one bar node
        // set default for all others
        this.bar_set_class = function(node, to_set_class) {
            Element.addClassName(cur, to_set_class);
            if(!this.bar_nodes) {
                return 0;
            }

            var i, cur;
            for(i=0; i < this.bar_nodes.length; i++) {
                cur = this.bar_nodes[i];
                Element.removeClassName(cur, to_set_class);
                if(cur == node) {
                    Element.addClassName(cur, to_set_class);
                }
            }
            return this.bar_nodes.length;
        };

        this.make_histogram_bar = function(index, width, height, error_size) {
            var node = document.createElement('DIV');
            node.className = 'bar';
            node.style.width = width + 'px';
            node.style.height = height + 'px';
            if(error_size) {
                var error_node = this.make_error_bar(error_size);
                node.appendChild(error_node);
            }
            node.onmouseover = this.on_bar_mouseover.bindAsEventListener(this);
            node.onmouseout = this.on_bar_mouseout.bindAsEventListener(this);
            node.onclick = this.on_bar_click.bindAsEventListener(this);
            node.histogram_index = index;
            return node;
        };

        this.make_error_bar = function(size) {
            var node = document.createElement('DIV');
            node.className = 'error_bar';
            node.style.top = -(size / 2.0) + 'px';
            node.style.height = size + 'px';
            var subnode = document.createElement('DIV');
            subnode.className = 'error_bar_top';
            node.appendChild(subnode);
            subnode = document.createElement('DIV');
            subnode.className = 'error_bar_line';
            node.appendChild(subnode);
            subnode = document.createElement('DIV');
            subnode.className = 'error_bar_bottom';
            node.appendChild(subnode);
            return node;
        };

/*
        this.init_thing = function() {

            var outer_node = $$('#'+this.container_id + ' .histogram')[0];
            var total_width = Element.getDimensions(outer_node).width - 2; // TODO hardcoded 2
            var minmax = this.get_data_range(this.params.data);
            var min = minmax[0];
            var max = minmax[1];

            var range = max - min;

            this.update_constrained_histogram();
            this.changed = true;
        };
*/
        this.draw_axis_lines = function() {
            
            var horizontal_lines_node = $$('#'+this.container_id + ' .horizontal_lines')[0];
            
            var line_spacing = this.params.histogram_max_height / 3; // TODO remove hard-coded 3
            for(i=0; i < 3; i++) {
                var line = this.make_horizontal_line(line_spacing * (i+1));
                horizontal_lines_node.appendChild(line);
            }

        }

        this.make_horizontal_line = function(bottom) {
            var node = document.createElement('DIV');
            node.className = 'line';
            node.style.bottom = bottom + 'px';
            return node;
        };

        this.make_histogram_labels = function() {
            var label_container = $$('#'+this.container_id + ' .bar_label_container .offset')[0];
            label_container.innerHTML = '';

            var i, label, offset, node;
            for(i=0; i < this.params.bar_labels.length; i++) {
                label = this.params.bar_labels[i];
                offset = (this.histogram_bar_width + this.params.bar_spacing) * i;
                node = this.make_histogram_label(label, offset);
                label_container.appendChild(node);
            }
        };

        this.make_histogram_label = function(label, offset) {
            var node = document.createElement('DIV');
            node.className = 'bar_label';
            node.style.left = offset + 'px';
            node.innerHTML = label;
            return node;
        };

        // abs(log2(val))
        this.log = function(val) {
            return Math.abs(Math.log(val) / Math.log(2));
        };

        // create main histogram
        this.bins = this.make_histogram_bins(params.data, params.bar_count);
        this.bars = this.make_histogram_bars();
        this.init_histogram(this.params.total_histogram_id, this.bars);
        this.draw_axis_lines();
        this.make_histogram_labels();
    }






};


