class fifo_write_read_seq extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_read_seq)

    function new(string name = "fifo_write_read_seq");
        super.new(name);
    endfunction

    task body();
        for (int i = 0; i < 10; i++) begin
            req = fifo_seq_item::type_id::create("req");
            start_item(req);
            if (!req.randomize() with { w_en == 1; r_en == 0; })
                `uvm_fatal("SEQ", "Randomization failed")
            finish_item(req);
        end
		
        #50;
        
        for (int i = 0; i < 10; i++) begin
            req = fifo_seq_item::type_id::create("req");
            start_item(req);
            if (!req.randomize() with { w_en == 0; r_en == 1; })
                `uvm_fatal("SEQ", "Randomization failed")
            finish_item(req);
        end
    endtask
endclass