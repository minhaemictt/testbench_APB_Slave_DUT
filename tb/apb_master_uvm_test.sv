class apb_master_uvm_test extends uvm_test;

    `uvm_component_utils(apb_master_uvm_test)

    apb_master_uvm_environment env;


    function new(string name = "apb_master_uvm_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = apb_master_uvm_environment::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        apb_master_uvm_sequence seq;
        phase.raise_objection(this);
        seq = apb_master_uvm_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

    function void final_phase(uvm_phase phase);
        //report the coverage for all
        `uvm_info("COV", $sformatf("Functional Coverage: %0f%%",
            env.agent.monitor.apb_cg.get_coverage()), UVM_LOW)
        //check which covergroup did not get cover
        `uvm_info("COV", $sformatf("pwrite_cg: %0f%%", 
            env.agent.monitor.apb_cg.pwrite_cg.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("pready_cg: %0f%%", 
            env.agent.monitor.apb_cg.pready_cg.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("pslverr_cg: %0f%%", 
            env.agent.monitor.apb_cg.pslverr_cg.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("paddr_cg: %0f%%", 
            env.agent.monitor.apb_cg.paddr_cg.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("phase_cg: %0f%%", 
            env.agent.monitor.apb_cg.phase_cg.get_coverage()), UVM_LOW)
    endfunction

endclass