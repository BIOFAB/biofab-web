
function debug(txt) {
    $('debug').innerHTML = txt;
}

function debug_append(txt) {
    $('debug').innerHTML += txt;
}

var ConstraintSlider = {

    sliders: [],

    init: function(params) {

        var compile_time_params = Object.extend({

        }, params || {});

        if(!$('constraint_slider_template')) {
            return null;
        }

        this.template = doT.template($('constraint_slider_template').text, undefined, compile_time_params);
    },

    create: function(container_id, params) {
     
        var slider = new this.slider_class(this, container_id, params);

        if(!slider) {
            return null;
        }

        this.sliders.push(slider);
        return slider;
    },


    destroy: function(slider) {

        var i;
        for(i=0; i < this.sliders.length; i++) {
            if(this.sliders[i] == slider) {
                this.sliders.splice(i, 1);
                return true;
            }
        }
        return false;
    },

    slider_class: function(parent, container_id, params) {

        this.parent = parent;
        this.unique = Math.floor(Math.random() * 100000000);
        this.changed = false;

        if(!$(container_id)) {
            return null;
        }

        this.container_id = container_id;
        this.params = Object.extend({
            log_scale: false,
            histogram_heights: params.heights,
            total_histogram_id: 'total_histogram_'+this.unique,
            constrained_histogram_id: 'constrained_histogram_'+this.unique,
            node_id: 'constraint_slider_'+this.unique
        }, params || {});

        var result = this.parent.template(this.params);
        if(result == '') {
            console.log("Error: ConstraintSlider is missing doT template");
            return null;
        }

        $(container_id).innerHTML = result;

        var widget = $$('#'+this.container_id + ' .constraint_slider')[0];
        if(!widget) {
            console.log("Error: ConstraintSlider could not find its html node");
            return null;
        }

        this.widget_dimensions = Element.getDimensions(widget);

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


        this.make_histogram_bins = function(data, bin_count, existing_bins) {
            var i;

            var minmax = this.get_data_range(data); // re-calculate data range
            var min = minmax[0];
            var max = minmax[1];

            var bin_size = (max - min) / bin_count;

            // create bins
            var bins = [];
            for(i=0; i < bin_count; i++) {

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
                if(i == (bin_count - 1)) {
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

            return bins;
        };


        this.init_histogram = function(container_id, bins, data_count) {

            if(!bins || (bins.length == 0)) {
                return null;
            }
            
            this.widget_width = $(this.params.node_id).getDimensions().width;

            var per_bar = Math.floor(this.widget_width / bins.length);
            var histogram_bar_spacing = 2;
            var histogram_bar_width = per_bar - histogram_bar_spacing;
            var histogram_left_offset = Math.floor(this.widget_width - histogram_bar_width * bins.length - histogram_bar_spacing * (bins.length - 1));

            var i;
            var pixels_per_data_entries = null;

            // set the normalization factor
            if(this.params.y_axis_max == 'dynamic') { // normalize based on a specified value
                var y_axis_max = 0;
                for(i=0; i < bins.length; i++) {
                    if(bins[i].data.length > y_axis_max) {
                        y_axis_max = bins[i].data.length;
                    }
                }
                this.params.y_axis_max = y_axis_max;
            }
            if(this.params.log_scale) {
                pixels_per_data_entry = this.params.histogram_max_height / Math.log(this.params.y_axis_max);
            } else {
                pixels_per_data_entry = this.params.histogram_max_height / this.params.y_axis_max;
            }

            // center the histogram
            $(this.params.total_histogram_id).style.left = histogram_left_offset / 2 + 'px';

            // append the nodes
            var node;
            for(i=0; i < bins.length; i++) {
                if(this.params.log_scale) {
                    height = Math.round(pixels_per_data_entry * Math.log(bins[i].data.length));
                } else {
                    height = Math.round(pixels_per_data_entry * bins[i].data.length);
                }
                node = this.make_histogram_bar(histogram_bar_width, height);
                node.style.left = (i * histogram_bar_width) + (i * histogram_bar_spacing) + 'px';
                $(container_id).appendChild(node);
            }
        };

        

        this.init_dragging = function() {
            var right_slider = $$('#'+this.container_id + ' .right_slider')[0];
            var left_slider = $$('#'+this.container_id + ' .left_slider')[0];
            var constrained_area = $$('#'+this.container_id + ' .constrained_area')[0];
            this.slider_dimensions = Element.getDimensions(right_slider);
            right_slider.onmousedown = this.right_slider_mousedown.bindAsEventListener(this);
            left_slider.onmousedown = this.left_slider_mousedown.bindAsEventListener(this);
            constrained_area.onmousedown = this.constrained_area_mousedown.bindAsEventListener(this);
        };

        this.right_slider_mousedown = function(e) {
            this.constrained_area = $$('#'+this.container_id + ' .constrained_area')[0];
            document.onmouseup = this.slider_mouseup.bindAsEventListener(this);
            var widget = $$('#'+this.container_id + ' .constraint_slider')[0];
            this.widget_offset = Element.cumulativeOffset(widget);

            document.onmousemove = this.right_slider_mousemove.bindAsEventListener(this);
            Event.stop(e); // stop event propagation
        };

        this.left_slider_mousedown = function(e) {
            this.constrained_area = $$('#'+this.container_id + ' .constrained_area')[0];
            document.onmouseup = this.slider_mouseup.bindAsEventListener(this);
            var widget = $$('#'+this.container_id + ' .constraint_slider')[0];
            this.widget_offset = Element.cumulativeOffset(widget);
            
            document.onmousemove = this.left_slider_mousemove.bindAsEventListener(this);
            Event.stop(e); // stop event propagation
        };

        this.constrained_area_mousedown = function(e) {
            this.constrained_area = $$('#'+this.container_id + ' .constrained_area')[0];
            document.onmouseup = this.slider_mouseup.bindAsEventListener(this);
            var widget = $$('#'+this.container_id + ' .constraint_slider')[0];
            this.widget_offset = Element.cumulativeOffset(widget);

            this.mousedown_x_offset = Event.pointer(e).x - Element.cumulativeOffset(this.constrained_area).left;

            document.onmousemove = this.constrained_area_mousemove.bindAsEventListener(this);
            Event.stop(e); // stop event propagation
        };

        this.left_slider_mousemove = function(e) {
            var point = Event.pointer(e);
            var left = Element.cumulativeOffset(this.constrained_area).left;

            var right = left - this.widget_offset.left + Element.getDimensions(this.constrained_area).width;

            var new_left = point.x - this.widget_offset.left - Math.floor(this.slider_dimensions.width / 2);

            // boundary checks

            if(new_left < 0) {
                new_left = 0;
            }

            if(new_left > (right - this.slider_dimensions.width)) {
                new_left = right - this.slider_dimensions.width;
            }

            var new_width = right - new_left
            if(new_width < 13) { // TODO remove hardcode
                new_width = 13;
            }

            this.constrained_area.style.left = new_left + 'px';
            this.constrained_area.style.width = new_width + 'px';
            this.slider_changed();
        };


        this.right_slider_mousemove = function(e) {
            var point = Event.pointer(e);
            var left = Element.cumulativeOffset(this.constrained_area).left;
            var new_width = point.x - left

            // keep it within the boundaries of the widget
            if(new_width < 13) { // TODO remove hardcoded number
                new_width = 13;
            }
            var new_right = left + new_width;
            if(new_right > (this.widget_offset.left + this.widget_dimensions.width) - 2) { // TODO hardcoded -2
                new_width = (this.widget_offset.left + this.widget_dimensions.width) - 2 - left;
            }

            this.constrained_area.style.width = new_width + 'px';
            this.slider_changed();
        };

        this.constrained_area_mousemove = function(e) {
            var point = Event.pointer(e);
            var left = Element.cumulativeOffset(this.constrained_area).left;

            var new_left = point.x - this.widget_offset.left - Math.floor(this.slider_dimensions.width / 2) - this.mousedown_x_offset + 5; // TODO why +5?
            var new_right = new_left - this.widget_offset.left + Element.getDimensions(this.constrained_area).width;
            var max_right = this.widget_dimensions.width - this.widget_offset.left;

            if(new_left < 0) {
                new_left = 0;
            }

            if(new_right > max_right) {
                new_left = this.widget_dimensions.width - Element.getDimensions(this.constrained_area).width - 2; // TODO hardcoded -2
            }

            this.constrained_area.style.left = new_left + 'px';
            this.slider_changed();
        };


        this.slider_mouseup = function(e) {
            if(this.changed) {
                this.on_change(this.constrain_data_min, this.constrain_data_max);
                this.changed = false;
            }
            document.onmousemove = this.nullfunc;
            this.constrained_area = null;
        };

        this.nullfunc = function() {
            return false;
        };

        this.make_histogram_bar = function(width, height) {
            var node = document.createElement('DIV');
            node.className = 'bar';
            node.style.width = width + 'px';
            node.style.height = height + 'px';
            return node;
        };

        this.slider_changed = function() {

            var outer_node = $$('#'+this.container_id + ' .constraint_slider')[0];
            var total_width = Element.getDimensions(outer_node).width - 2; // TODO hardcoded 2
            var constrained_area_node = $$('#'+this.container_id + ' .constrained_area')[0];
            var left = Element.cumulativeOffset(constrained_area_node).left - Element.cumulativeOffset(outer_node).left;
            var width = Element.getDimensions(constrained_area_node).width;

            var constrained_size = width - left;

            var left_ratio = left / total_width;
            var right_ratio = (left + width) / total_width;

            var minmax = this.get_data_range(this.params.data);
            var min = minmax[0];
            var max = minmax[1];

            var range = max - min;

            this.constrain_data_min = left_ratio * range + min;
            this.constrain_data_max = right_ratio * range + min;
            
            this.update_min_max_labels();

            this.update_constrained_histogram();
            this.changed = true;
        };


        this.update_min_max_labels = function() {
            
            var min_label = $$('#'+this.container_id + ' .constrained_area .left_slider .label')[0];
            var max_label = $$('#'+this.container_id + ' .constrained_area .right_slider .label')[0];
            
            min_label.innerHTML = Math.round(this.constrain_data_min * 100) / 100;
            max_label.innerHTML = Math.round(this.constrain_data_max * 100) / 100;

        };
 
        this.update_constrained_histogram = function() {



            this.constrained_data = [];
            var i;
            for(i=0; i < this.params.data.length; i++) {
                if((this.params.data[i] >= this.constrain_data_min) && (this.params.data[i] <= this.constrain_data_max)) {
                    this.constrained_data.push(this.params.data[i]);
                }
            }

            this.constrained_bins = this.make_histogram_bins(this.constrained_data, this.params.bin_count, this.bins);

            $(this.params.constrained_histogram_id).innerHTML = '';
            this.init_histogram(this.params.constrained_histogram_id, this.constrained_bins, this.constrained_data.length);

        };

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
            node.style.bottom = bottom + this.widget_dimensions.height - 1 + 'px';
            return node;
        };

        // create main histogram
        this.bins = this.make_histogram_bins(params.data, params.bin_count);
        this.init_histogram(this.params.total_histogram_id, this.bins, params.data.length);

        this.draw_axis_lines();
        this.slider_changed();
        this.init_dragging();
    }






};


