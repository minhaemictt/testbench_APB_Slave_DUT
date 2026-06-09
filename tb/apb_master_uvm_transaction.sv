class apb_master_uvm_transaction extends uvm_sequence_item; // nowadays, nearly no one use uvm_transaction anymore
    //register to the uvm factory
    `uvm_object_utils_begin(apb_master_uvm_transaction)
        `uvm_field_int(paddr,   UVM_ALL_ON)
        `uvm_field_int(pwrite,  UVM_ALL_ON)
        `uvm_field_int(pwdata,  UVM_ALL_ON)
        // `uvm_field_int(psel,    UVM_ALL_ON)
        // `uvm_field_int(penable, UVM_ALL_ON)
        `uvm_field_int(prdata,   UVM_ALL_ON)
        `uvm_field_int(pready,  UVM_ALL_ON)
        `uvm_field_int(pslverr,  UVM_ALL_ON)
    `uvm_object_utils_end

    
    //generate stimulus
    rand logic [31:0]   paddr;
    rand logic          pwrite;
    rand logic [31:0]   pwdata;
    // logic          psel;
    // logic          penable;


    //ouput
    logic [31:0]        prdata;
    logic               pready;
    logic               pslverr;

    //add constraint
    constraint addr_range { paddr inside {[0:80]}; }


    //in UVM, as every class is the child class from a base class in the UVM library, we have to have a slightly different function new here
    function new(string name = "apb_master_uvm_transaction");
        super.new(name);
    endfunction

endclass

// General
// - At the start of every class, we would need to assign the class module to the UVM factory, using the command
// `uvm_object_utils(class_name)
// `uvm_component_utils(class_name)
// 	+ if we wish to use any utility function, just add the 
// 	`uvm_field_int(variable_name,UVM_ALL_ON) (do more research for the alternative)

