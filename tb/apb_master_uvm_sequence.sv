class apb_master_uvm_sequence extends uvm_sequence #(apb_master_uvm_transaction); //don't forget the #() which is parameterize a value that is not numerical values
    //register the class to the uvm factory

    //macro don't need the semicolon;
    `uvm_object_utils(apb_master_uvm_sequence)

    function new (string name = "apb_master_uvm_sequence");
        super.new(name);
    endfunction

    virtual task body();
        apb_master_uvm_transaction tr;
        uvm_phase phase = get_starting_phase(); //getting new phase starting from the UVM 1.2+ version

        // apb_master_uvm_transaction::type_id::create("tr"); ~ new();
        tr = apb_master_uvm_transaction::type_id::create("tr");
        //null to check for who is the top sequence
        if (phase != null) begin
            phase.raise_objection(this);
        end

        //error manage ?
        repeat (200) begin
                tr = apb_master_uvm_transaction::type_id::create("tr");
                start_item(tr);
                tr.randomize();
                finish_item(tr);
        end

        if (phase != null) begin
            phase.drop_objection(this);
        end

        //raise-drop only one time in the class
    endtask
endclass