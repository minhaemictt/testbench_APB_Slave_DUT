interface apb_master_uvm_interface (input logic clk);

    logic               prstn;

    logic               psel;
    logic               penable;
    logic [31:0]        paddr;
    logic               pwrite;
    logic [31:0]        pwdata;

    logic [31:0]        prdata;
    logic               pready;
    logic               pslverr;


    //it is not neccessary to declare wire size    
    clocking cb_drv @(posedge clk);
        output          prstn;
        output          psel;
        output          penable;
        output 		    paddr;
        output 		    pwrite;
        output 		    pwdata;

        input  		    prdata;
        input           pready;
        input           pslverr;
    endclocking

  clocking cb_mon @(posedge clk);
        input           prstn;
        input           psel;
        input           penable;
        input 		    paddr;
        input           pwrite;
        input 		    pwdata;

        input 		    prdata;
        input           pready;
        input           pslverr;
    endclocking

    sequence SETUP;
    psel == 1 && penable == 0;
    endsequence

    sequence ACCESS;
        psel == 1 && penable == 1;
    endsequence

    //Protocol checks:

    // penable never high when psel is low
    // SETUP must be followed by ACCESS next cycle
    // pready must be high during ACCESS (psel=1, penable=1), not SETUP
    // pready must deassert after ACCESS completes
    // paddr must remain stable during ACCESS phase
    // pwdata must remain stable during ACCESS phase
    //checking reset function


    //don't forget the normal operation vs reset operation

    //normal operation
    assert property (@(posedge clk) disable iff (prstn !== 1) SETUP |=> ACCESS) else $error("SETUP not followed by ACCESS");
    assert property (@(posedge clk) disable iff (prstn !== 1) ACCESS |-> (pready == 1 && $stable(paddr) && $stable(pwdata))) else $error("ACCESS phase: pready not high or signals not stable");
    assert property (@(posedge clk) disable iff (prstn !== 1) SETUP |-> pready !== 1) else $error("pready asserted during SETUP which should only assert in ACCESS");

    assert property (@(posedge clk) disable iff (prstn !== 1) psel == 0 |-> penable == 0) else $error("penable high without psel");

    assert property (@(posedge clk) disable iff (prstn !== 1) ACCESS |=> pready !== 1) else $error("pready not deasserted after ACCESS completed");

    //reset
    assert property (@(posedge clk) $fell(prstn) |=> (pready == 0 && pslverr == 0 && prdata == 0)) else $error("fail to reset");

    // assert property (@(posedge clk) disable iff (prstn !== 1) (psel == 0 && penable == 0 |=> pready == 0 && pslverr == 0)) else $error("pready and pslverr must be low when penable and psel are 0");
    // assert property (@(posedge clk) disable iff (prstn !== 1) (psel == 1 && penable == 0) |-> SETUP) else $error("SETUP not followed by ACCESS");

endinterface: apb_master_uvm_interface