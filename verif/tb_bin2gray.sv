`timescale 1ns/1ps

module tb_bin2gray;
    parameter WIDTH = 4;

    logic [WIDTH-1:0] bin_in;
    logic [WIDTH-1:0] gray_out;

    logic [WIDTH-1:0] prev_gray;
    logic [WIDTH-1:0] expected;
    logic [WIDTH-1:0] xor_res;
    logic [WIDTH-1:0] gray_last;
    logic [WIDTH-1:0] gray_zero;

    bin2gray #(.WIDTH(WIDTH)) bin2gray_instance (
        .bin(bin_in),
        .gray(gray_out)
    ); 

    initial begin
        $dumpfile("tb_bin2gray.vcd");
        $dumpvars(0, tb_bin2gray);

        prev_gray = 4'b0;
        expected  = 4'b0;
        xor_res   = 4'b0;
        gray_last = 4'b0;
        gray_zero = 4'b0;

        for (int i = 0; i < (2**WIDTH); i++) begin
            bin_in = i; 
            #1;

            expected = i ^ (i >> 1);

            assert (gray_out == expected) 
                else $error("Mismatch at binary %d: Expected %b, Got %b", i, expected, gray_out);

            if (i > 0) begin
                xor_res = gray_out ^ prev_gray;
                assert ($countones(xor_res) == 1) 
                    else $error("Bit-change error at binary %d: More than 1 bit changed!", i);
            end

            prev_gray = gray_out;
        end

        gray_last = (2**WIDTH - 1) ^ ((2**WIDTH - 1) >> 1);
        gray_zero = 4'b0;
        xor_res = gray_last ^ gray_zero;
        
        assert ($countones(xor_res) == 1) 
            else $error("Cyclic property failed during wrap-around!");

        $display("SUCCESS: ALL TESTS PASSED!");
        $finish;
    end
endmodule