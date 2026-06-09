`timescale 1ns/1ns
`include "uvm_macros.svh"
`include "apb_master_uvm_interface.sv"
`include "apb_master_uvm_package.sv"   

module tb_top;

    import uvm_pkg::*;
    import apb_master_uvm_package::*;

    logic clk;
    apb_master_uvm_interface apb_if(.clk(clk));

    initial begin
        clk = 0;
        apb_if.prstn = 0;
        #20
        apb_if.prstn = 1;
    end
    always begin
        #5 clk = ~clk;
    end
    
    apb_v3_sram dut(
        .PCLK    (clk),
        .PRESETn (apb_if.prstn),
        .PSEL    (apb_if.psel),
        .PENABLE (apb_if.penable),
        .PWRITE  (apb_if.pwrite),
        .PADDR   (apb_if.paddr),
        .PWDATA  (apb_if.pwdata),
        .PRDATA  (apb_if.prdata),
        .PREADY  (apb_if.pready),
        .PSLVERR (apb_if.pslverr)
    );

    initial begin
        $dumpfile("apb_master_uvm_top.vcd");
        $dumpvars(0, tb_top);                 
    end

    initial begin
        // set interface into the config
        uvm_config_db #(virtual apb_master_uvm_interface)::set(null, "uvm_test_top.*", "vif", apb_if);
        run_test("apb_master_uvm_test");
    end

    

endmodule