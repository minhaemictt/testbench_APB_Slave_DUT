class apb_ram_test extends apb_slave_uvm_test;
    `uvm_component_utils(apb_ram_test)

    function new(string name = "apb_ram_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        //This is the old UVM syntax
        // apb_slave_uvm_transaction::type_id::set_type_override_by_type(apb_ram_transaction::get_type());
        // apb_slave_uvm_monitor::type_id::set_type_override_by_type(apb_ram_monitor::get_type());
        // apb_slave_uvm_scoreboard::type_id::set_type_override_by_type(apb_ram_scoreboard::get_type());

        //the correct one for UVM 1.2 must be
        uvm_factory factory = uvm_factory::get();

        factory.set_type_override_by_type(apb_slave_uvm_transaction::get_type(), apb_ram_transaction::get_type());
        factory.set_type_override_by_type(apb_slave_uvm_monitor::get_type(), apb_ram_monitor::get_type());
        factory.set_type_override_by_type(apb_slave_uvm_scoreboard::get_type(), apb_ram_scoreboard::get_type());
        super.build_phase(phase);
    endfunction

    function void final_phase(uvm_phase phase);
        apb_ram_monitor ram_mon;
        super.final_phase(phase);
        $cast(ram_mon, env.agent.monitor);
        `uvm_info("COV", $sformatf("paddr_cg: %0f%%", ram_mon.apb_ram_cg.paddr_cg.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("pwrite_cg: %0f%%", ram_mon.apb_ram_cg.pwrite_cg.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("pstrb_cg: %0f%%", env.agent.monitor.apb_cg.pstrb_cg.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("pslverr_cg: %0f%%", ram_mon.apb_ram_cg.pslverr_cg.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("phase_cg: %0f%%", ram_mon.apb_ram_cg.phase_cg.get_coverage()), UVM_LOW)
    endfunction

endclass