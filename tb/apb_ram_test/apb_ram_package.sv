package apb_ram_package;
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import apb_slave_uvm_package::*;

    `include "apb_ram_transaction.sv"
    `include "apb_ram_monitor.sv"
    `include "apb_ram_scoreboard.sv"
    `include "apb_ram_test.sv"
endpackage