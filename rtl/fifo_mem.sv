module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter DEPTH      = 2 ** ADDR_WIDTH
)(
    input logic clk_w,
    input logic w_en,
    input logic [ADDR_WIDTH-1:0] waddr,
    input logic [DATA_WIDTH-1:0] wdata,
    input logic [ADDR_WIDTH-1:0] raddr,

    output logic [DATA_WIDTH-1:0] rdata
);
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @( posedge clk_w) begin
        if (w_en) begin
            mem[waddr] <= wdata;
        end
    end

    // An asynchronous read just requires an address
    // and the memory responds instantly regardless of any clock. 
    assign rdata = mem[raddr];
endmodule