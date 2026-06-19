`timescale 1ns/1ps
`include "uvm_macros.svh"
`include "apb_slave_uvm_interface.sv"
`include "apb_slave_uvm_package.sv"  
`include "apb_ram_package.sv"

module apb_ram_top_flatport;

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
        //waveform
        $dumpfile("apb_ram_top_flatport.vcd");
        $dumpvars(0, apb_ram_top_flatport);      

        //sdf
        $sdf_annotate("delays.sdf", apb_ram_top_flatport.dut);           
    end

    initial begin
        uvm_config_db #(virtual apb_slave_uvm_interface)::set(null, "uvm_test_top.*", "vif", apb_if);
        run_test("apb_ram_test");
    end

endmodule