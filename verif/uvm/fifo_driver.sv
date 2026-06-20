class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)

    // Virtual interface to pull the signals from the fifo interface
    virtual fifo_if vif;

    function new(string name = "fifo_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Could not get vif from config_db")
    endfunction

    task run_phase(uvm_phase phase);
        wait (vif.rst_w == 0 && vif.rst_r == 0);
        forever begin
            seq_item_port.get_next_item(req);

            if (req.w_en) begin
                @(posedge vif.clk_w);
                #1;
                vif.w_en = 1;
                vif.wdata = req.wdata;

                @(posedge vif.clk_w);
                #1;
                vif.w_en = 0;
            end else if (req.r_en) begin
                @(posedge vif.clk_r);
                #1;
                vif.r_en = 1;

                @(posedge vif.clk_r);
                #1;
                vif.r_en = 0;
            end

            seq_item_port.item_done();
        end
    endtask
endclass