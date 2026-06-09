class apb_master_uvm_scoreboard extends uvm_scoreboard;
    `uvm_component_utils (apb_master_uvm_scoreboard)
    uvm_analysis_imp #(apb_master_uvm_transaction, apb_master_uvm_scoreboard) mon2sb;
    logic [31:0]                                                              event_log_mem [int]; //using the associative memory here

    function new (string name = "apb_master_uvm_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //function void write (); this write function must have a parameter inside, which mostly our transaction here
    //just like sequence and driver, the scoreboard and the monitor have established strong handshake that the scoreboard must wait after the monitor to create a mailbox to get that transaction to compare
    function void write (apb_master_uvm_transaction tr);
        logic [31:0] expected_value;
        //pslverr check for outside the scope
        if (tr.paddr >= 64) begin
            if (tr.pslverr !== 1'b1) begin
            `uvm_error("pslverr", "should be 1")
            return;
            end
        end
        //pslverr check for inside the scope
        else begin
            if (tr.pslverr !== 1'b0) begin
                `uvm_error("pslverr", "should be 0");
            end

            //event log check for read and write
            if (tr.pwrite == 1'b1) begin
                event_log_mem[tr.paddr] = tr.pwdata;
                `uvm_info("data log success", $sformatf("event log: paddr=%0h, pdata=%0h", tr.paddr, tr.pwdata), UVM_LOW);
            end
            else begin
                //built-in function for the associative array to check if this array has been written or not
                if (event_log_mem.exists(tr.paddr)) begin
                    expected_value = event_log_mem[tr.paddr];
                end 
                else begin
                    expected_value = 32'h0;
                end
                if (tr.prdata === expected_value) begin
                    `uvm_info("APB_Data_pass", $sformatf("match paddr: %0h expected: %0h actual: %0h", tr.paddr, expected_value, tr.prdata), UVM_LOW)
                end else begin
                    `uvm_error("APB_Data_fail", $sformatf("mismatch paddr: %0h expected: %0h actual: %0h", tr.paddr, expected_value, tr.prdata))
                end
            end
        end
    endfunction
    //uvm_error does not have the verbosity level

    function void build_phase (uvm_phase phase);
        //always have to include this line above in every build_phase function
        super.build_phase(phase);
        //phase = get_starting_phase(); this can only be run inside sequence
        mon2sb = new("mon2sb", this); //command to create an object for the mailbox
    endfunction
endclass