class apb_master_uvm_agent extends uvm_agent;

    `uvm_component_utils(apb_master_uvm_agent)

    apb_master_uvm_sequencer    sequencer;
    apb_master_uvm_driver       driver;
    apb_master_uvm_monitor      monitor;

    // uvm_active_passive_enum is_active; improve later for reusability


    function new(string name = "apb_master_uvm_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            driver    = apb_master_uvm_driver::type_id::create("driver", this);
            sequencer = apb_master_uvm_sequencer::type_id::create("sequencer", this);
        end
        monitor   = apb_master_uvm_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass