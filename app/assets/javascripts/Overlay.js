var Overlay = {

    init: function() { return false },
    
    status: 'hidden',
    hide_callback: null, // hide_callback is called before hiding starts
    
    show_partial: function(url, params, hide_callback) {
        this.hide_callback = hide_callback;

        new Ajax.Request(url, {
            method: 'get',
            parameters: params,
            onSuccess: this.show_partial_callback.bindAsEventListener(this)
        });
        
        this.update_html('loading...');
        if(this.status != 'shown') {
            this.show();
        }
    },
    
    
    // show details in right-hand panel
    show_partial_callback: function(transport) {
        this.update_html(transport.responseText);
    },
    
    
    update_html: function(html) {
        $('overlay_content').innerHTML = html;
    },

    show_html: function(html, hide_callback) {
        this.hide_callback = hide_callback;
        this.update_html(html);
        if(this.status != 'shown') {
            this.show();
        }
    },
    
    show: function() {
        this.status = 'showing';
        $('overlay').style.display = 'block';
        
        this.shown_bound = this.shown.bindAsEventListener(this);
        Event.observe($('overlay_grayout'), 'transitionend', this.shown_bound);
        Event.observe($('overlay_grayout'), 'webkitTransitionEnd', this.shown_bound); // webkit compatibility
        
        // bug-workaround for firefox 10.0.2 (possibly others)
        setTimeout(this.show2, 10);
    },
    
    show2: function() {
        $('overlay_grayout').style.opacity = 0.3;
        $('overlay_box').style.opacity = 1.0;
    },
    
    // called when fade-in complete
    shown: function(e) {
        this.status = 'shown';
        Event.stopObserving($('overlay_grayout'), 'transitionend', this.shown_bound);
        Event.stopObserving($('overlay_grayout'), 'webkitTransitionEnd', this.shown_bound); // webkit compatibility
    },
    
    hide: function() {      
        this.status = 'hiding';

        if(this.hide_callback) {
            this.hide_callback();
            this.hide_callback = null;
        }

        this.hidden_bound = this.hidden.bindAsEventListener(this)
        Event.observe($('overlay_grayout'), 'transitionend', this.hidden_bound);
        Event.observe($('overlay_grayout'), 'webkitTransitionEnd', this.hidden_bound); // webkit compatibility
        
        $('overlay_grayout').style.opacity = 0;
        $('overlay_box').style.opacity = 0;
    },
    
    // called when fade-out completed
    hidden: function(e) {
        this.status = 'hidden';
        Event.stopObserving($('overlay_grayout'), 'transitionend', this.hidden_bound);
        Event.stopObserving($('overlay_grayout'), 'webkitTransitionEnd', this.hidden_bound); // webkit compatibility
        $('overlay').style.display = 'none';
    }
    
}
