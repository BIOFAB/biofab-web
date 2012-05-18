

var Simple = {

    init: function() {

        this.spinner_template = doT.template($('spinner_template').text, null, null);

    },

    show_plasmid: function(url, design_id) {
        var loading_html = this.spinner_template({message: "Fetching annotated plasmid sequence."});

        Overlay.show_html(loading_html);

        new Ajax.Request(url, {
            method: 'get',
            parameters: {
                design_id: design_id,
                bc_design_id: design_id
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




