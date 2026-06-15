`timescale 1ns/1ns
`include "uvm_macros.svh"
`include "apb_slave_uvm_interface.sv"
`include "apb_slave_uvm_package.sv"  
`include "apb_ram_package.sv"


module tb_top;

    import uvm_pkg::*;
    import apb_slave_uvm_package::*;
    import apb_ram_package::*;


    logic clk;
    
    apb_slave_uvm_interface apb_if(.clk(clk));

    initial begin
        clk = 0;
        apb_if.prst = 0;
        #20
        apb_if.prst = 1;
        #20
        apb_if.prst = 0;
    end

    always begin
        #5 clk = ~clk;
    end
    
    // Flatport DUT — no intermediate interface or modport needed,
    // UVM interface signals connect directly to the flat ports.
    taxi_apb_ram_flatport dut(
        .clk              (clk),
        .rst              (apb_if.prst),

        .s_apb_paddr      (apb_if.paddr),
        .s_apb_pprot      (apb_if.pprot),
        .s_apb_psel       (apb_if.psel),
        .s_apb_penable    (apb_if.penable),
        .s_apb_pwrite     (apb_if.pwrite),
        .s_apb_pwdata     (apb_if.pwdata),
        .s_apb_pstrb      (apb_if.pstrb),
        .s_apb_pready     (apb_if.pready),
        .s_apb_prdata     (apb_if.prdata),
        .s_apb_pslverr    (apb_if.pslverr),
        .s_apb_pauser     (apb_if.pauser),
        .s_apb_pwuser     (apb_if.pwuser),
        .s_apb_pruser     (apb_if.pruser),
        .s_apb_pbuser     (apb_if.pbuser)
    );

    initial begin
        $dumpfile("apb_slave_uvm_top.vcd");
        $dumpvars(0, tb_top);                 
    end

    initial begin
        uvm_config_db #(virtual apb_slave_uvm_interface)::set(null, "uvm_test_top.*", "vif", apb_if);
        // to run the ram test, we must override the slave_uvm_test instead of leaving it like this run_test("apb_slave_uvm_test");
        run_test("apb_ram_test");
    end

endmodule
