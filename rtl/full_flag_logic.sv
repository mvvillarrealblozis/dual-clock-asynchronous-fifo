module full_flag_logic #(
    parameter ADDR_WIDTH = 4
)(
    input logic [ADDR_WIDTH:0] gray_write_ptr,
    input logic [ADDR_WIDTH:0] gray_read_ptr_sync_w,

    output logic full
);  
    /*
        When the FIFO is full the MSB of the write and read ptrs
        will always differ because of the "lap." When the wptr MSB is 1 that
        means that it has lapped the read ptr. 

        There is no need to convert the gray to binary because we are checking
        for a specific bit pattern that is consistent across all gray code values.
    */
    always_comb begin
        if (
            gray_write_ptr[ADDR_WIDTH] != gray_read_ptr_sync_w[ADDR_WIDTH] && 
            gray_write_ptr[ADDR_WIDTH-1] != gray_read_ptr_sync_w[ADDR_WIDTH-1] &&
            gray_write_ptr[ADDR_WIDTH-2:0] == gray_read_ptr_sync_w[ADDR_WIDTH-2:0]
        ) begin
            full = 1;
        end else begin
            full = 0;
        end
    end

endmodule