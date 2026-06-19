class apb_ram_monitor extends apb_slave_uvm_monitor;
    `uvm_component_utils(apb_ram_monitor)

    // Coverage bins tuned for ADDR_W=4 (16B RAM, byte addresses 0 to 15)
    covergroup apb_ram_cg;
        paddr_cg: coverpoint tr.paddr {
            bins paddr_valid            = {[0:2047]};
            bins paddr_boundary_invalid = {2048};
            bins paddr_invalid          = {[2049:32'hFFFFFFFF]};
        }
        pwrite_cg: coverpoint tr.pwrite {
            bins pwrite_write = {1};
            bins pwrite_read  = {0};
        }
        // pprot_cg: coverpoint tr.pprot {
        //     bins pprot_valid = {0};
        // }
        // pauser_cg: coverpoint tr.pauser {
        //     bins pauser_valid  = {0};
        // }
        // pwuser_cg: coverpoint tr.pwuser {
        //     bins pwuser = {0};
        // }
        pready_cg: coverpoint tr.pready {
            bins pready_high = {1};
            // bins pready_low  = {0};
        }
        pslverr_cg: coverpoint tr.pslverr {
            bins pslverr_error     = {1};
            bins pslverr_non_error = {0};
        }
        phase_cg: coverpoint {vif.cb_mon.psel, vif.cb_mon.penable} {
            bins idle   = {2'b00};
            bins setup  = {2'b10};
            bins access = {2'b11};
        }
        cross pwrite_cg, pslverr_cg;
        cross pwrite_cg, paddr_cg;
    endgroup

    function new (string name ="apb_ram_monitor", uvm_component parent = null);
        super.new(name, parent);
        apb_ram_cg = new();
    endfunction

    virtual function void sample_fc();
        super.sample_fc();
        apb_ram_cg.sample();
    endfunction

endclass
