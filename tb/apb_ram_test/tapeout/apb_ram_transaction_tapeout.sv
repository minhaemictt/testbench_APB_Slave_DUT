class apb_ram_transaction extends apb_slave_uvm_transaction;
    //don't forget to assign this to the uvm factory and the function new also even for the child class
    `uvm_object_utils(apb_ram_transaction)

    function new(string name = "apb_ram_transaction");
        super.new(name);
    endfunction

    // ADDR_W = 4, so RAM depth = 2^(4-2) = 4 words (byte-addressed: 0 to 15)
    // Valid word-aligned addresses: 0 to 12 (step 4)
    // Boundary address (last valid): 12
    // First out-of-bounds byte address: 16
    constraint addr_range {
        paddr dist {
            [0:2047]             :/ 70,
            2048                 := 10,  
            [2049:32'hFFFFFFFF]  :/ 20   
        };
    }

    constraint pprot_valid  { pprot  == 3'b000; }
    constraint pauser_valid { pauser == 1'b0;   }
    constraint pwuser_valid { pwuser == 1'b0;   }

endclass
