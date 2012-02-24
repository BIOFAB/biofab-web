


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