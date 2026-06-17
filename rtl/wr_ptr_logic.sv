module wr_ptr_logic #(
    parameter ADDR_WIDTH = 4
)(
    input logic clk_w,
    input logic rst_w,
    input logic w_en,
    input logic full,

    output logic [ADDR_WIDTH-1:0] waddr,
    output logic [ADDR_WIDTH:0] gray_write_ptr
);  
    // We use an extra bit for the pointer to be able to tell if the fifo is full/empty
    // Without it, there would be a case where the write and read pointers would be at the 
    // same address but there would be no way to tell if its full or empty. Using an extra bit
    // we can tell when one of the pointers has "lapped" the other. 
    logic [ADDR_WIDTH:0] wptr;

    always_ff @(posedge clk_w or posedge rst_w) begin
        if (rst_w) begin
            wptr <= 0;
        end else if (w_en && !full) begin
            wptr <= wptr + 1;
        end
    end
    assign waddr = wptr[ADDR_WIDTH-1:0];

    // Gray pointer is combinational because it's purely a function of the current value of wptr with no state of its own
    assign gray_write_ptr = wptr ^ (wptr >> 1);
endmodule