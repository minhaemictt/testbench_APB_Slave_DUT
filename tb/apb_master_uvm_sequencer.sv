class apb_master_uvm_sequencer extends uvm_sequencer #(apb_master_uvm_transaction);
    `uvm_component_utils (apb_master_uvm_sequencer)

    //only set the parent to null as it is the default value, but when we need to implement these classes in different class, it is better to write the correct parent
    function new (string name ="apb_master_uvm_sequencer", uvm_component parent = null); //don't forget that the function new needs a parent
        super.new(name, parent);
    endfunction

endclass