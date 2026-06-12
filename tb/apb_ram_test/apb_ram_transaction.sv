    class apb_ram_transaction extends apb_slave_uvm_transaction;
    //don't for get to assign this to the uvm factory and the function new also even for the child class
        `uvm_object_utils(apb_ram_transaction)

        function new(string name = "apb_ram_transaction");
            super.new(name);
        endfunction
        
    //the parameter said ADDR_W=16 so it is 16 bus wide, which is 0: 2^16 - 1
        constraint addr_range {
        paddr dist {
        [0:65534]            :/ 60,
        65535                := 10,
        65536                := 10,
        [65537:32'hFFFFFFFF] :/ 20
    };
}
        constraint pprot_valid  { pprot  == 3'b000; }
        constraint pauser_valid   { pauser == 1'b0;   }
        constraint pwuser_valid  { pwuser == 1'b0;   }

    endclass