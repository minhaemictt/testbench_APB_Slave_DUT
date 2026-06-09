class apb_master_uvm_environment extends uvm_env;
    `uvm_component_utils(apb_master_uvm_environment)

    apb_master_uvm_agent      agent;
    apb_master_uvm_scoreboard scoreboard;

    function new(string name = "apb_master_uvm_environment", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = apb_master_uvm_agent::type_id::create("agent", this);
        scoreboard = apb_master_uvm_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.mon2sb.connect(scoreboard.mon2sb);
    endfunction

endclass