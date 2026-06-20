class fifo_seq_item #(
    parameter DATA_WIDTH = 8
) extends uvm_sequence_item;
    `uvm_object_utils(fifo_seq_item)


    rand logic [DATA_WIDTH-1:0] wdata;
    rand logic w_en;
    rand logic r_en;

    logic [DATA_WIDTH-1:0] rdata;
    logic full;
    logic empty;

    constraint valid_op {
        w_en != r_en;
    }

    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction 

endclass