`include "uvm_macros.svh"
import uvm_pkg::*;
`timescale 1ns/1ns
`include "uvm_macros.svh"
`include "apb_slave_uvm_interface.sv"
`include "taxi_apb_if.sv"
`include "apb_slave_uvm_package.sv"  
`include "apb_ram_package.sv"


module tb_top;

    import uvm_pkg::*;
    import apb_slave_uvm_package::*;
    import apb_ram_package::*;


    logic clk;
    
    apb_slave_uvm_interface apb_if(.clk(clk));
    taxi_apb_if apb_bus();

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
    
    taxi_apb_ram dut(
        .clk     (clk),
        .rst     (apb_if.prst),
        .s_apb   (apb_bus.slv)
    );


    //this RTL logic is using modport, that is why we have to do the assigning
    assign apb_bus.paddr   = apb_if.paddr;
    assign apb_bus.pprot   = apb_if.pprot;
    assign apb_bus.psel    = apb_if.psel;
    assign apb_bus.penable = apb_if.penable;
    assign apb_bus.pwrite  = apb_if.pwrite;
    assign apb_bus.pwdata  = apb_if.pwdata;
    assign apb_bus.pstrb   = apb_if.pstrb;
    assign apb_bus.pauser  = apb_if.pauser;
    assign apb_bus.pwuser  = apb_if.pwuser;

    assign apb_if.prdata   = apb_bus.prdata;
    assign apb_if.pready   = apb_bus.pready;
    assign apb_if.pslverr  = apb_bus.pslverr;
    assign apb_if.pruser   = apb_bus.pruser;
    assign apb_if.pbuser   = apb_bus.pbuser;

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