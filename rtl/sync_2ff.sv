module sync_2ff #(
    parameter WIDTH = 4
)(
    input logic clk_dst,
    input logic rst_dst,
    input logic [WIDTH-1:0] d,

    output logic [WIDTH-1:0] q
);
    // The unstable flop, the bit sampled in here is considered unstable
    logic [WIDTH-1:0]ff1;

    /*
        The stable flop, at this point one full clock cycle has passed
        so when a signal is sampled from ff2 it is almost guarenteed that 
        this is a stable signal
    */
    logic [WIDTH-1:0] ff2;

    /* 
        With gray code, q will only ever take on the old value or new value
        from the first flip flop since one bit changes at a time
    */

    always_ff @(posedge clk_dst or posedge rst_dst ) begin
        if (rst_dst) begin
            ff1 <= '0;
            ff2 <= '0;
        end else begin
            ff1 <= d;
            ff2 <= ff1;
        end
    end

    assign q = ff2;
endmodule


/* sync_2ff #(.WIDTH(WIDTH)) u_sync_wptr(
    .clk_dst(clk_r),
    .rst_dst(rst_r),
    .d(gray_write_ptr),
    .q(gray_write_ptr_sync_r)
);

sync_2ff #(.WIDTH(WIDTH)) u_sync_rptr (
    .clk_dst (clk_w),
    .rst_dst (rst_w),
    .d       (gray_read_ptr),        
    .q       (gray_read_ptr_sync_w)
);
*/