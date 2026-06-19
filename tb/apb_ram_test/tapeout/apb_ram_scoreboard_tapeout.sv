class apb_ram_scoreboard extends apb_slave_uvm_scoreboard;
    `uvm_component_utils(apb_ram_scoreboard)

    function new(string name = "apb_ram_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void checker_sco(apb_slave_uvm_transaction tr);
        if (tr.paddr >= 2048) begin
            if (tr.pslverr !== 1'b1) begin
                `uvm_error("PSLVERR", "should be 1")
            end
        end
        else begin
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

        if(tr.paddr < 2048) begin
            super.checker_sco(tr);
        end
    endfunction
endclass
