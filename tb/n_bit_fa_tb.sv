timeunit 1ns;
timeprecision 1ps;

parameter N = 8;

module n_bit_fa_tb;   

    logic [N-1:0] a,b;
    logic ci;
    logic [N-1:0] sum;
    logic co;

    n_bit_fa #(.N(N)) dut (
        .a(a),
        .b(b),
        .ci(ci),
        .sum(sum),
        .co(co)
    );

    initial begin
        $dumpfile("waveform.vcd");$dumpvars(0, n_bit_fa_tb);

        a = 8'd5;
        b = 8'd10;
        ci = 1'b0;
        #1 assert ({1'b0, a} + {1'b0, b} + ci== sum + co*256) 
        else   $error("Test failed: %d + %d + %d != %d + %d*256", a, b, ci, sum, co);

        repeat (10) begin
            #9;
            a = $urandom_range(0, 255);
            b = $urandom_range(0, 255);
            ci = $urandom_range(0, 1);
            #1 
            if ({1'b0, a} + {1'b0, b} + {8'b0, ci} == {co, sum})
                $display("PASS: %d + %d + %d = %d", a, b, ci, {co, sum});
            else
                $error("FAIL: %d + %d + %d != %d", a, b, ci, {co, sum});
            // else   $error("Test failed: %d + %d + %d != %d + %d*256", a, b, ci, sum, co);
        end


    end

    
endmodule