class fifo_scoreboard #(
    parameter DATA_WIDTH = 8
) extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) ap;

    logic [DATA_WIDTH-1:0] ref_queue[$];
    int pass_count;
    int fail_count;
    logic [DATA_WIDTH-1:0] expected;

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void write(fifo_seq_item tr);
        // Case 1: write
        if (tr.w_en) begin
            ref_queue.push_back(tr.wdata);
        // Case 2: read
        end else if (tr.r_en) begin
            // Queue empty 
            if (ref_queue.size() == 0) begin
                `uvm_error("QUEUE_EMPTY", "Error popping from queue, queue is empty")
            end else begin
                expected = ref_queue.pop_front();
                if (expected == tr.rdata) begin
                    pass_count = pass_count + 1;
                    `uvm_info("PASS", $sformatf("Match: expected=%0d actual=%0d", expected, tr.rdata), UVM_LOW)
                end else begin
                    fail_count = fail_count + 1;
                    `uvm_error("FAIL", $sformatf("Mismatch: expected=%0d actual=%0d", expected, tr.rdata))
                end
            end
        end
    endfunction 
endclass 