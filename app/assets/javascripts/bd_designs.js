

var BCDDesign = {

    bcd_bar_labels: [
        'BCD1',
        'BCD2',
        'BCD5',
        'BCD6',
        'BCD7',
        'BCD8',
        'BCD9',
        'BCD10',
        'BCD11',
        'BCD12',
        'BCD13',
        'BCD14',
        'BCD15',
        'BCD16',
        'BCD17',
        'BCD18',
        'BCD19',
        'BCD20',
        'BCD21',
        'BCD22',
        'BCD23',
        'BCD24'
    ],

    mcd_bar_labels: [
        'MCD1',
        'MCD2',
        'MCD5',
        'MCD6',
        'MCD7',
        'MCD8',
        'MCD9',
        'MCD10',
        'MCD11',
        'MCD12',
        'MCD13',
        'MCD14',
        'MCD15',
        'MCD16',
        'MCD17',
        'MCD18',
        'MCD19',
        'MCD20',
        'MCD21',
        'MCD22',
        'MCD23',
        'MCD24'
    ],
    
    
    goi_bar_labels: [
        'GFP',
        'coPMK-36-GFP',
        'coCellulase-36-GFP',
        'PA-36-GFP',
        'sfGFP-36-GFP',
        'RFP-36-GFP',
        'Lacl-36-GFP',
        'TetR-36-GFP',
        'AraC-36-GFP',
        'TetR-full-GFP',
        'RFP',
        'coPMK-36-RFP',
        'coCellulase-36-RFP',
        'PA-36-RFP',
        'sfGFP-36-RFP',
        'RFP-36-RFP',
        'Lacl-36-RFP',
        'TetR-36-RFP',
        'AraC-36-RFP'
    ],
    

    nilfunc: function(e) {
        return false;
    },

    gen_random_data: function(count, scale_factor) {
        scale_factor = scale_factor || 1;

        // random data
        var data = [];
        var i;
        for(i=0; i < count; i++) {
            data.push(Math.random() * scale_factor);
        }
        return data;
    },

    init: function(bcd_data, bcd_sd, mcd_data, mcd_sd) {

        this.spinner_template = doT.template($('spinner_template').text, null, null);

        Histogram.init();
        
        this.bcd_histogram = Histogram.create('bcd_histogram', {
            data_is_bar_heights: true,
            data: bcd_data, //this.gen_random_data(this.bcd_bar_labels.length, 100),
            errors: bcd_sd, //this.gen_random_data(this.bcd_bar_labels.length, 10),
            bar_labels: this.bcd_bar_labels,
            bar_spacing: 10,
            histogram_max_height: 'inherit',
            y_axis_max: 'dynamic', // Can also be 'dynamic'. If you specify this, then you _must_not_ have any bins with more entries than y_axis_max. If you do, the widget will exceed histogram_max_height.
            horizontal_lines: true,
            log_scale: false,
            on_mouseover: this.bcd_bin_mouseover.bind(this),
            on_mouseout: this.bcd_bin_mouseout.bind(this),
            on_click: this.bcd_bin_click.bind(this)
        });

        this.mcd_histogram = Histogram.create('mcd_histogram', {
            data_is_bar_heights: true,
            data: mcd_data, //this.gen_random_data(this.mcd_bar_labels.length, 100),
            errors: mcd_sd, //this.gen_random_data(this.mcd_bar_labels.length, 10),
            bar_labels: this.mcd_bar_labels,
            bar_spacing: 10,
            histogram_max_height: 'inherit',
            y_axis_max: 'dynamic', // Can also be 'dynamic'. If you specify this, then you _must_not_ have any bins with more entries than y_axis_max. If you do, the widget will exceed histogram_max_height.
            horizontal_lines: true,
            log_scale: false,
            on_mouseover: this.mcd_bin_mouseover.bind(this),
            on_mouseout: this.mcd_bin_mouseout.bind(this),
            on_click: this.mcd_bin_click.bind(this)
        });
        
    },

    bcd_bin_mouseover: function(node, index, is_simulated, value, error, label, per_bar_param) {
//        console.log('Over: ' + index + ', ' + value + ', ' + error + ', ' + label);
        if(!is_simulated) {
            this.mcd_histogram.simulate_mouseover(index);
        }
        return true;
    },
    bcd_bin_mouseout: function(node, index, is_simulated, value, error, label, per_bar_param) {
//        console.log('Over: ' + index + ', ' + value + ', ' + error + ', ' + label);
        if(!is_simulated) {
            this.mcd_histogram.simulate_mouseout(index);
        }
        return true;
    },

    bcd_bin_click: function(node, index, is_simulated, value, error, label, per_bar_param) {
//        console.log('bcd bar click: ' + index + ', ' + value + ', ' + error + ', ' + label);

        new Ajax.Request('/bd_designs/get_per_goi_data', {
            method: 'get',
            parameters: {
                fpu_name: label
            },
            onSuccess: this.bcd_bin_click_callback.bindAsEventListener(this, index, label)
        });        

        if(!is_simulated) {
            this.mcd_histogram.simulate_click(index);
        }

        return true; // return true tells the Histogram to set the 'active' class for the clicked bar
    },

    bcd_bin_click_callback: function(transport, index, label) {

//        var data = this.gen_random_data(this.goi_bar_labels.length, 100);
//        var error_data = this.gen_random_data(this.goi_bar_labels.length, 10);

        var obj = transport.responseText.evalJSON(true);
        
        var data = obj.data;
        var error_data = obj.errors;
        var labels = obj.labels;
        var per_bar_params = obj.params;
        
        var histogram = this.make_goi_histogram('bcd_goi_histogram', labels, data, error_data, this.bcd_goi_histogram_click.bind(this), per_bar_params);
    },


    mcd_bin_mouseover: function(node, index, is_simulated, value, error, label, per_bar_param) {
//        console.log('Over: ' + index + ', ' + value + ', ' + error + ', ' + label);
        if(!is_simulated) {
            this.bcd_histogram.simulate_mouseover(index);
        }
        return true;
    },
    mcd_bin_mouseout: function(node, index, is_simulated, value, error, label, per_bar_param) {
//        console.log('Over: ' + index + ', ' + value + ', ' + error + ', ' + label);
        if(!is_simulated) {
            this.bcd_histogram.simulate_mouseout(index);
        }
        return true;
    },

    mcd_bin_click: function(node, index, is_simulated, value, error, label, per_bar_param) {
//        console.log('bcd bar click: ' + index + ', ' + value + ', ' + error + ', ' + label);

        new Ajax.Request('/bd_designs/get_per_goi_data', {
            method: 'get',
            parameters: {
                fpu_name: label
            },
            onSuccess: this.mcd_bin_click_callback.bindAsEventListener(this, index, label)
        });        

        return true; // return true tells the Histogram to set the 'active' class for the clicked bar
    },


    mcd_bin_click_callback: function(transport, index, label) {

        var obj = transport.responseText.evalJSON(true);
        
        var data = obj.data;
        var error_data = obj.errors;
        var labels = obj.labels;
        
        var histogram = this.make_goi_histogram('mcd_goi_histogram', labels, data, error_data, this.mcd_goi_histogram_click.bind(this));
    },

    make_goi_histogram: function(container_id, labels, data, error_data, click_callback, per_bar_params) {

        var goi_histogram = Histogram.create(container_id, {
            data_is_bar_heights: true,
            data: data,
            errors: error_data,
            bar_labels: labels,
            per_bar_params: per_bar_params,
            bar_spacing: 10,
            histogram_max_height: 'inherit',
            y_axis_max: 'dynamic', // Can also be 'dynamic'. If you specify this, then you _must_not_ have any bins with more entries than y_axis_max. If you do, the widget will exceed histogram_max_height.
            horizontal_lines: true,
            log_scale: false,
            on_mouseover: this.nilfunc,
            on_mouseout: this.nilfunc,
            on_click: click_callback
        });

        return goi_histogram;
    },

    bcd_goi_histogram_click:  function(node, index, is_simulated, value, error, label, per_bar_param) {
        this.show_goi_overlay(per_bar_param);
    },

    mcd_goi_histogram_click: function(e) {
        console.log('MCD GOOOOOI?');
    },


    show_goi_overlay: function(per_bar_param) {
        if(!per_bar_param || !per_bar_param.bc_design_id) {
            console.log("show_goi_overlay did not receive a bc_design_id");
            return false;
        }


        var loading_html = this.spinner_template({message: "Fetching annotated plasmid sequence."});

        Overlay.show_html(loading_html);

        new Ajax.Request('/bd_designs/get_plasmid_json', {
            method: 'get',
            parameters: {
                bc_design_id: per_bar_param.bc_design_id
            },
            onSuccess: this.goi_overlay_callback.bindAsEventListener(this)
        });        
    },

    goi_overlay_callback: function(transport) {
        if(!FlashWidgets) {
            console.log("Error: FlashWidgets.js does not appear to be loaded.");
            return false;
        }
        var obj = transport.responseText.evalJSON(true);

        // TODO kinda hackish
        var html = "<h3>Plasmid sequence for pFAB123</h3><div id='flash_widgets_container'></div>";

        Overlay.show_html(html, this.overlay_hide_callback.bind(this));

        FlashWidgets.show_and_load_obj('flash_widgets_container', obj);
        console.log("showing plasmid sequence");
    },

    overlay_hide_callback: function() {
        FlashWidgets.hide();
    }

}

