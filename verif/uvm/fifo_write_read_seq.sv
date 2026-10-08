class fifo_write_read_seq extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_read_seq)

    function new(string name = "fifo_write_read_seq");
        super.new(name);
    endfunction

    task body();
        repeat (20)  send_op(1, 1, 0);   // Phase 1: fill (16) + 4 writes against full
        repeat (20)  send_op(1, 0, 1);   // Phase 2: drain (16) + 4 reads against empty
        repeat (200) send_op(0, 0, 0);   // Phase 3: mixed traffic from the dist
        repeat (20)  send_op(1, 0, 1);   // Phase 4: final drain
    endtask

    task send_op(bit fixed, bit w, bit r);
        req = fifo_seq_item::type_id::create("req");
        start_item(req);
        if (fixed) begin
            if (!req.randomize() with { w_en == w; r_en == r; })
                `uvm_fatal("SEQ", "Randomization failed")
        end else begin
            if (!req.randomize())
                `uvm_fatal("SEQ", "Randomization failed")
        end
        finish_item(req);
    endtask
endclass