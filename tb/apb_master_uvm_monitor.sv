class apb_master_uvm_monitor extends uvm_monitor;

    `uvm_component_utils(apb_master_uvm_monitor)

    uvm_analysis_port #(apb_master_uvm_transaction) mon2sb;
    virtual apb_master_uvm_interface                           vif;
    apb_master_uvm_transaction 								   tr;

    //because we dont have the psel and penable inside the transaction, so we have to use the one in the clocking block monitor
    covergroup apb_cg;
        pwrite_cg: coverpoint tr.pwrite {
            bins pwrite_write = {1};
            bins pwrite_read  = {0};
        }
        pready_cg: coverpoint tr.pready {
            bins pready_high = {1};
            bins pready_low  = {0};
        }
        pslverr_cg: coverpoint tr.pslverr {
            bins pslverr_error     = {1};
            bins pslverr_non_error = {0};
        }
        paddr_cg: coverpoint tr.paddr {
            bins paddr_valid        = {[0:63]};
            bins paddr_out_of_range = {[64:80]};
        }
        phase_cg: coverpoint {vif.cb_mon.psel, vif.cb_mon.penable} {
            bins idle   = {2'b00};
            bins setup  = {2'b10};
            bins access = {2'b11};
        }
        cross pwrite_cg, paddr_cg;
        cross paddr_cg, pslverr_cg;
        cross pwrite_cg, pready_cg;
    endgroup


    function new(string name = "apb_master_uvm_monitor", uvm_component parent = null);
        super.new(name, parent);
        apb_cg = new (); //don't forget to construct out the coverage group
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon2sb = new("mon2sb", this);
        if(!uvm_config_db #(virtual apb_master_uvm_interface)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(vif.cb_mon);
            tr = apb_master_uvm_transaction::type_id::create("tr");
            //input
            tr.paddr   = vif.cb_mon.paddr;
            tr.pwrite  = vif.cb_mon.pwrite;
            tr.pwdata  = vif.cb_mon.pwdata;
            //output
            tr.prdata  = vif.cb_mon.prdata;
            tr.pready  = vif.cb_mon.pready;
            tr.pslverr = vif.cb_mon.pslverr;
            //coverage capture
            apb_cg.sample();

            //only send valid to scoreboard
            if(vif.cb_mon.psel && vif.cb_mon.penable && vif.cb_mon.pready) begin
                mon2sb.write(tr);
            end
        end 
    endtask

endclass