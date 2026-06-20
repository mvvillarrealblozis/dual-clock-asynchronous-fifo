interface fifo_if #(
    parameter DATA_WIDTH = 8
) (
    input logic clk_w,
    input logic clk_r
);
    logic rst_w;
    logic rst_r;
    logic w_en;
    logic [DATA_WIDTH-1:0] wdata;
    logic full;
    logic r_en;
    logic empty;
    logic [DATA_WIDTH-1:0] rdata;

endinterface