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
	
    int write_while_full = 0;
    int read_while_empty = 0;

    function void write(fifo_seq_item tr);
        if (tr.w_en) begin
            if (tr.full) begin
                write_while_full++;
                `uvm_info("WR_FULL", "Write attempted while full: correctly dropped", UVM_MEDIUM)
            end else
                ref_queue.push_back(tr.wdata);
        end
        if (tr.r_en) begin
            if (tr.empty) begin
                read_while_empty++;
                `uvm_info("RD_EMPTY", "Read attempted while empty: correctly ignored", UVM_MEDIUM)
            end else if (ref_queue.size() == 0) begin
                `uvm_error("UNDERFLOW", "DUT returned data but model queue is empty")
            end else begin
                expected = ref_queue.pop_front();
                if (expected == tr.rdata) pass_count++;
                else begin
                    fail_count++;
                    `uvm_error("FAIL", $sformatf("Mismatch: expected=%0h actual=%0h", expected, tr.rdata))
                end
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        if (fail_count != 0)        `uvm_error("REPORT", $sformatf("%0d data mismatches", fail_count))
        if (pass_count == 0)        `uvm_error("REPORT", "No reads were checked")
        if (ref_queue.size() != 0)  `uvm_error("REPORT", $sformatf("%0d entries never read out", ref_queue.size()))
        if (write_while_full == 0)  `uvm_error("REPORT", "Never exercised write-while-full")
        if (read_while_empty == 0)  `uvm_error("REPORT", "Never exercised read-while-empty")
        `uvm_info("REPORT", $sformatf("pass=%0d fail=%0d wr_while_full=%0d rd_while_empty=%0d",
                    pass_count, fail_count, write_while_full, read_while_empty), UVM_LOW)
    endfunction
endclass 