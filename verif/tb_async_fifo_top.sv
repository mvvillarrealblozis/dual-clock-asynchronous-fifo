`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "fifo_if.sv"
`include "fifo_seq_item.sv"
`include "fifo_sequencer.sv"
`include "fifo_driver.sv"
`include "fifo_monitor.sv"
`include "fifo_scoreboard.sv"
`include "fifo_agent.sv"
`include "fifo_env.sv"
`include "fifo_write_read_seq.sv"
`include "fifo_test.sv"

module tb_async_fifo_top;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    logic clk_w;
    logic clk_r;

    fifo_if #(.DATA_WIDTH(DATA_WIDTH)) vif_inst (
        .clk_w(clk_w),
        .clk_r(clk_r)
    );

    async_fifo_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk_w  (vif_inst.clk_w),
        .rst_w  (vif_inst.rst_w),
        .w_en   (vif_inst.w_en),
        .wdata  (vif_inst.wdata),
        .full   (vif_inst.full),
        .clk_r  (vif_inst.clk_r),
        .rst_r  (vif_inst.rst_r),
        .r_en   (vif_inst.r_en),
        .rdata  (vif_inst.rdata),
        .empty  (vif_inst.empty)
    );



    // Write clock — 10ns period
    initial clk_w = 0;
    always #5 clk_w = ~clk_w;

    // Read clock — different frequency, 7ns period (creates an irregular ratio)
    initial clk_r = 0;
    always #3.5 clk_r = ~clk_r;

    initial begin
        vif_inst.rst_w = 1;
        vif_inst.rst_r = 1;
        vif_inst.w_en = 0;
        vif_inst.r_en = 0;
        #20;
        vif_inst.rst_w = 0;
        vif_inst.rst_r = 0;
    end

    initial begin
        uvm_config_db #(virtual fifo_if)::set(null, "*", "vif", vif_inst);
        run_test("fifo_base_test");
    end

endmodule
