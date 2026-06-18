module rd_ptr_logic #(
    parameter ADDR_WIDTH = 4
)(
    input logic clk_r,
    input logic rst_r,
    input logic r_en,
    input logic empty,

    output logic [ADDR_WIDTH-1:0] raddr,
    output logic [ADDR_WIDTH:0] gray_read_ptr
);  
    // We use an extra bit for the pointer to be able to tell if the fifo is full/empty
    // Without it, there would be a case where the write and read pointers would be at the 
    // same address but there would be no way to tell if its full or empty. Using an extra bit
    // we can tell when one of the pointers has "lapped" the other. 
    logic [ADDR_WIDTH:0] rptr;

    always_ff @(posedge clk_r or posedge rst_r) begin
        if (rst_r) begin
            rptr <= 0;
        end else if (r_en && !empty) begin
            rptr <= rptr + 1;
        end
    end
    assign raddr = rptr[ADDR_WIDTH-1:0];

    // Gray pointer is combinational because it's purely a function of the current value of wptr with no state of its own
    assign gray_read_ptr = rptr ^ (rptr >> 1);
endmodule