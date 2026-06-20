class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    virtual fifo_if vif;
    uvm_analysis_port #(fifo_seq_item) ap;
    
    function new(string name = "fifo_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Could not get vif from config_db")
    endfunction

    task run_phase(uvm_phase phase);
        fork
            // Block 1 watches clk_w
            forever begin
                @(posedge vif.clk_w);
                if (vif.w_en) begin
                    fifo_seq_item tr;
                    tr = fifo_seq_item::type_id::create("tr");
                    tr.wdata = vif.wdata;
                    tr.full = vif.full;
                    tr.w_en = 1;
                    ap.write(tr);
                end
            end

            // Block 2 watches clk_r
            forever begin
                @(posedge vif.clk_r);
                if (vif.r_en) begin
                    fifo_seq_item tr;
                    tr = fifo_seq_item::type_id::create("tr");
                    tr.rdata = vif.rdata;
                    tr.empty = vif.empty;
                    tr.r_en = 1;
                    ap.write(tr);
                end
            end
        join_none
    endtask
endclass