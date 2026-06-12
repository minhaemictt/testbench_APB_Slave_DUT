class apb_ram_scoreboard extends apb_slave_uvm_scoreboard;
    `uvm_component_utils(apb_ram_scoreboard)
    
    function new(string name = "apb_ram_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual function void checker_sco(apb_slave_uvm_transaction tr);
        //adding return here helps the scoreboard to not check out of address data as it is only to check for the function of pslverr
        if (tr.paddr >= 65536) begin
            if (tr.pslverr !== 1'b1) begin
                `uvm_error("PSLVERR", "should be 1")
            end
            return;
        end
        else 
        begin
            if (tr.pslverr !== 1'b0) begin
                `uvm_error("PSLVERR", "should be 0");
            end
        end

        if (tr.pruser !== 0) begin
            `uvm_error("PRUSER", "expected 0")
        end
        if (tr.pbuser !== 0) begin
            `uvm_error("PBUSER", "expected 0")
        end

        //in most case, we should declare all the checking before declare the original function
        super.checker_sco(tr);
    endfunction
endclass