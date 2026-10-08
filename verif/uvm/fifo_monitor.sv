class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    virtual fifo_if vif;
    uvm_analysis_port #(fifo_seq_item) ap;

    // covergroup definition
    covergroup fifo_cg;
        cp_op : coverpoint {vif.w_en, vif.r_en} {
            bins idle       = {2'b00};
            bins write_only = {2'b10};
            bins read_only  = {2'b01};
            bins both       = {2'b11};
        }
        cp_state : coverpoint {vif.full, vif.empty} {
            bins partial = {2'b00};
            bins empty   = {2'b01};
            bins full    = {2'b10};
            illegal_bins full_and_empty = {2'b11};
        }
        cx_op_state : cross cp_op, cp_state;
    endgroup

    function new(string name = "fifo_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
        fifo_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Could not get vif from config_db")
    endfunction

    task run_phase(uvm_phase phase);
        fork
            forever begin
                @(posedge vif.clk_w);
                #2;
                if (vif.rst_w == 0) fifo_cg.sample(); 
                if (vif.w_en) begin
                    fifo_seq_item tr;
                    tr = fifo_seq_item::type_id::create("tr");
                    tr.wdata = vif.wdata;
                    tr.full  = vif.full;
                    tr.w_en  = 1;
                    ap.write(tr);
                end
            end

            forever begin
                @(posedge vif.clk_r);
                #2;
                if (vif.r_en) begin
                    fifo_seq_item tr;
                    tr = fifo_seq_item::type_id::create("tr");
                    tr.rdata = vif.rdata;
                    tr.empty = vif.empty;
                    tr.r_en  = 1;
                    ap.write(tr);
                end
            end
        join_none
    endtask

    // print coverage at end of test
    function void report_phase(uvm_phase phase);
        `uvm_info("COV", $sformatf("cp_op=%0.1f%%  cp_state=%0.1f%%  cross=%0.1f%%",
                  fifo_cg.cp_op.get_coverage(),
                  fifo_cg.cp_state.get_coverage(),
                  fifo_cg.cx_op_state.get_coverage()), UVM_LOW)
    endfunction
endclass