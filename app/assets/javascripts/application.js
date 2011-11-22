
Object.extend(Function.prototype, (function() {

  function bindAsEventListener2(context) {
      var __method = this, args = slice.call(arguments, 1);
      return function(event, arg1) {
          var a = update([event || window.event], args);
          return __method.apply(context, arg1, a);
      }
  }
})());

var FlowCyte = {

    field_names: ['organism',
                  'promoter', 
                  'five_prime_utr', 
                  'cds',
                  'terminator'],

    hide_master_fields: false,
   
    plate_cols: 12,
    plate_rows: 8,
    
    init: function(p) {
        this.p = p;
        
        this.hide_master_fields = !!($('hide_master').checked);
        $('hide_master').onchange = this.toggle_master_fields.bindAsEventListener(this);

        this.enable_autocomplete_and_update('organism', p.organism_descriptors);
        this.enable_autocomplete_and_update('promoter', p.promoter_descriptors);
        this.enable_autocomplete_and_update('five_prime_utr', p.five_prime_utr_descriptors);
        this.enable_autocomplete_and_update('cds', p.cds_descriptors);
        this.enable_autocomplete_and_update('terminator', p.terminator_descriptors);
        this.enable_autocomplete_and_update('channel', p.channel_descriptors);

        this.update_layout();

    },

    toggle_master_fields: function(e) {
        this.hide_master_fields = e.target.checked;
        this.update_layout();
    },

    enable_autocomplete_and_update: function(node_id, data) {
        this.enable_autocomplete(node_id, data);
        this.enable_onselect_update(node_id);
    },

    enable_autocomplete: function(node_or_id, data) {
        var jnode_or_id;
        if(typeof(node_or_id) == 'string') {
            jnode_or_id = '#'+node_or_id;
        } else {
            jnode_or_id = node_or_id;
        }
        jQuery(jnode_or_id).autocomplete({source: data, delay: 0});
    },

    enable_onselect_update: function(node_or_id) {
        var self = this;
        var jnode_or_id
        if(typeof(node_or_id) == 'string') {
            jnode_or_id = '#'+node_or_id;
        } else {
            jnode_or_id = node_or_id;
        }
        jQuery(jnode_or_id).bind('autocompleteselect', function(e, ui) {
            $(node_or_id).value = ui.item.value;
            self.update_layout();
        });
        $(node_or_id).onchange = function(e) {
            if(e.target.value == '') {
                self.update_layout();
            }
        }
    },

    gen_text_field: function(node_id, node_name, placeholder, autocomplete_data) {
        var node = document.createElement('input');
        node.className = 'table_autocomplete';
        node.id = node_id;
        node.name = node_name;
        node.type = 'text';
        node.placeholder = placeholder;
        this.enable_autocomplete(node, autocomplete_data);
        return node;
    },

    gen_label: function(node_id, text) {
        var node = document.createElement('div');
        node.className = 'table_label';
        node.id = node_id;
        node.innerHTML = text;
        return node;
    },

    update_layout: function() {

        var row, col, row_id, col_id, node_id, node, topmost, leftmost;
        for(row=0; row <= this.plate_rows; row++) {
            row_id = 'row_'+(row);            
            topmost = !!(row == 0);

            for(col=0; col <= this.plate_cols; col++) {
                col_id = row_id+'_col_'+(col);
                leftmost = !!(col == 0);

                this.update_fields(row, col, topmost, leftmost);

            }
        }
    },
   
    update_fields: function(row, col) {
        if((row == 0) && (col == 0)) {
            return;
        }
        this.update_field(row, col, 'organism', '<organism>', this.p.organism_descriptors);
        this.update_field(row, col, 'promoter', '<promoter>', this.p.promoter_descriptors);
        this.update_field(row, col, 'five_prime_utr', "<5' UTR>", this.p.five_prime_utr_descriptors);
        this.update_field(row, col, 'cds', "<CDS>", this.p.cds_descriptors);
        this.update_field(row, col, 'terminator', "<Terminator>", this.p.terminator_descriptors);
        this.update_field(row, col, 'channel', "<Channel>", this.p.channel_descriptors);
    },

    update_field: function(row, col, master_id, placeholder, autocomplete_data, col_precedence) {
        var col_id = 'row_'+row+'_col_'+col;
        var node_id = col_id+'_'+master_id;
        var node_name = '[data]['+row+']['+col+']['+master_id+']';
        var master_row_node_id = 'row_'+row+'_col_0_'+master_id;
        var master_col_node_id = 'row_0_col_'+col+'_'+master_id;

        if(!$(node_id).handlers_set) { // first run. set handlers
//            var new_node = this.gen_text_field(node_id, node_name, placeholder, autocomplete_data);
//            $(col_id).appendChild(new_node);
            this.enable_autocomplete(node_id, autocomplete_data);
            if((row == 0) || (col == 0)) {
                this.enable_onselect_update(node_id);
            }
            $(node_id).handlers_set = true;
        }
        
        var master_row_value, master_col_value;
        if((row == 0) || (col == 0)) {
            master_row_value = '';
            master_col_value = '';
        } else {
            master_row_value = $(master_row_node_id).value;
            master_col_value = $(master_col_node_id).value;    
        }
        
        var pvalue = '';
        if((master_row_value != '') && (master_col_value != '')) {
            if(col_precedence) {
                pvalue = master_col_value;
            } else {
                pvalue = master_row_value;
            }
        } else if(master_row_value != '') {
            pvalue = master_row_value;
        } else if(master_col_value != '') {
            pvalue = master_col_value;
        } else {
            pvalue = $(master_id).value;
        }

        $(node_id).removeClassName('hide');

        if(pvalue == '') {
            $(node_id).placeholder = placeholder;
            $(node_id).removeClassName('ok');
        } else {
            $(node_id).placeholder = pvalue;
            $(node_id).addClassName('ok');
            
            // don't show if it's a master field
            // and the setting is to hide
            if(this.hide_master_fields) {
                if(($(master_id).value != '') && ($(node_id).value == '')) {
                    $(node_id).addClassName('hide');
                }
            }
        }
        new_node = null;
    },

    pre_save: function() {
/* disabled check

        var row, col, row_id, col_id, i, node_id, placeholder;
        for(row=0; row <= this.plate_rows; row++) {
            row_id = 'row_'+(row);            
            for(col=0; col <= this.plate_cols; col++) {
                col_id = row_id+'_col_'+(col);
                if((row == 0) && (col == 0)) {
                    continue;
                }
                for(i=0; i < this.field_names.length; i++) {
                    node_id = col_id+'_'+this.field_names[i];
                    if($(node_id).value == '') {
                        placeholder = $(node_id).placeholder;

                        // TODO this check could be prettier
                        if((placeholder[0] == '<') && (placeholder[placeholder.length - 1] == '>')) {
                            alert("Some fields are missing values!");
                            return false;
                        }
                    }
                }
            }
        }
*/
        return true;
    }

/*
    update_field: function(col_id, master_id, placeholder, autocomplete_data) {
        node_id = col_id+'_'+master_id;

        var new_node;
        if(this.locked[master_id]) {
            new_node = this.gen_label(node_id, $(master_id).value)
        } else {
            new_node = this.gen_text_field(node_id, placeholder, autocomplete_data);
        }

        if($(node_id)) {
            $(node_id).replace(new_node);
        } else {
            $(col_id).appendChild(new_node);
        }
        new_node = null;
    }
*/
};






