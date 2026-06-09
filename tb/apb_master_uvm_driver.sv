class apb_master_uvm_driver extends uvm_driver #(apb_master_uvm_transaction);
    `uvm_component_utils(apb_master_uvm_driver);

    virtual apb_master_uvm_interface                   vif;
    
    function new (string name = "apb_master_uvm_transaction", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase (uvm_phase phase);
        //variable declaration must be at the top of any command
        apb_master_uvm_transaction tr;
        if (!uvm_config_db#(virtual apb_master_uvm_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV", "Could not get vif from config_db")
        end

        forever begin
            // tr = apb_master_uvm_transaction::type_id::create("tr");/ one important thing here is get_next_item will go into the sequence to get the object tr, which would not require to create an object
            seq_item_port.get_next_item(tr);
            
            @(vif.cb_drv);

            vif.cb_drv.paddr   <= tr.paddr;
            vif.cb_drv.pwrite  <= tr.pwrite;
            vif.cb_drv.pwdata  <= tr.pwdata;
            vif.cb_drv.psel    <= 1'b1;
            vif.cb_drv.penable <= 1'b0;

            @(vif.cb_drv);
            vif.cb_drv.penable <= 1'b1;

            //mimic APB behaviour
            while (vif.cb_drv.pready !== 1'b1) begin
                @(vif.cb_drv);
            end

            //ending the cycle
            @(vif.cb_drv);
            vif.cb_drv.psel    <= 1'b0;
            vif.cb_drv.penable <= 1'b0;
            
            seq_item_port.item_done();  //when to use (tr) and get_respone_time
            //get_next_item goes hand in hand with item_done
        end
    endtask
endclass