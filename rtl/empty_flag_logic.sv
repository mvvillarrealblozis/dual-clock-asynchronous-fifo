module empty_flag_logic #(
    parameter ADDR_WIDTH = 4
)(
    input logic [ADDR_WIDTH:0] gray_read_ptr,
    input logic [ADDR_WIDTH:0] gray_write_ptr_sync_r,

    output logic empty
);  
    /*
        Gray coded values are only equal if their underlying
        binary values are equal, therefor you do not need to 
        decode them when comparing
    */
    assign empty = (gray_read_ptr == gray_write_ptr_sync_r);
endmodule