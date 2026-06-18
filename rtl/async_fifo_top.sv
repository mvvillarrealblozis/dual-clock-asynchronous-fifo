module async_fifo_top #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    // Write domain
    input  logic clk_w,
    input  logic rst_w,
    input  logic w_en,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic full,

    // Read domain
    input  logic clk_r,
    input  logic rst_r,
    input  logic r_en,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic empty
);

    // -------------------------------------------------------------------------
    // Internal nets
    // -------------------------------------------------------------------------

    // wr_ptr_logic → sync_2ff(u_sync_wptr) & full_flag_logic
    logic [ADDR_WIDTH:0] gray_write_ptr;

    // rd_ptr_logic → sync_2ff(u_sync_rptr) & empty_flag_logic
    logic [ADDR_WIDTH:0] gray_read_ptr;

    // sync_2ff(u_sync_wptr) → empty_flag_logic
    logic [ADDR_WIDTH:0] gray_write_ptr_sync_r;

    // sync_2ff(u_sync_rptr) → full_flag_logic
    logic [ADDR_WIDTH:0] gray_read_ptr_sync_w;

    // wr_ptr_logic → fifo_mem
    logic [ADDR_WIDTH-1:0] waddr;

    // rd_ptr_logic → fifo_mem
    logic [ADDR_WIDTH-1:0] raddr;

    // gating logic → fifo_mem & wr_ptr_logic
    logic w_en_gated;

    // -------------------------------------------------------------------------
    // Gating logic — only logic allowed in top level
    // -------------------------------------------------------------------------
    assign w_en_gated = w_en & ~full;

    // -------------------------------------------------------------------------
    // Submodule instantiations
    // -------------------------------------------------------------------------

    fifo_mem #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_fifo_mem (
        .clk_w  (clk_w),
        .w_en   (w_en_gated),
        .waddr  (waddr),
        .wdata  (wdata),
        .raddr  (raddr),
        .rdata  (rdata)
    );

    wr_ptr_logic #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_wr_ptr_logic (
        .clk_w          (clk_w),
        .rst_w          (rst_w),
        .w_en           (w_en_gated),
        .full           (full),
        .waddr          (waddr),
        .gray_write_ptr (gray_write_ptr)
    );

    rd_ptr_logic #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_rd_ptr_logic (
        .clk_r         (clk_r),
        .rst_r         (rst_r),
        .r_en          (r_en),
        .empty         (empty),
        .raddr         (raddr),
        .gray_read_ptr (gray_read_ptr)
    );

    // Write pointer crossing to read domain
    sync_2ff #(
        .WIDTH (ADDR_WIDTH + 1)
    ) u_sync_wptr (
        .clk_dst (clk_r),
        .rst_dst (rst_r),
        .d       (gray_write_ptr),
        .q       (gray_write_ptr_sync_r)
    );

    // Read pointer crossing to write domain
    sync_2ff #(
        .WIDTH (ADDR_WIDTH + 1)
    ) u_sync_rptr (
        .clk_dst (clk_w),
        .rst_dst (rst_w),
        .d       (gray_read_ptr),
        .q       (gray_read_ptr_sync_w)
    );

    full_flag_logic #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_full_flag_logic (
        .gray_write_ptr      (gray_write_ptr),
        .gray_read_ptr_sync_w(gray_read_ptr_sync_w),
        .full                (full)
    );

    empty_flag_logic #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_empty_flag_logic (
        .gray_read_ptr       (gray_read_ptr),
        .gray_write_ptr_sync_r(gray_write_ptr_sync_r),
        .empty               (empty)
    );

endmodule