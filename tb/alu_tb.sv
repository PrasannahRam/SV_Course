class Random_sel;
    rand bit [2:0] num;
    constraint c {num inside {[0:7]};};

    function new();
        this.num = 3'd0;
    endfunction
endclass

class Random_Num #(parameter WIDTH = 8);
    rand bit signed [WIDTH-1:0] num;
endclass

module alu_tb;
    timeunit 1ns/1ps;
    parameter WIDTH = 8;
    logic signed [WIDTH-1:0] a, b, alu_out;
    logic [2:0] alu_sel;
    logic zero, negative,overflow;

    alu #(.WIDTH(WIDTH)) dut (
        .a(a),
        .b(b),
        .alu_sel(alu_sel),
        .alu_out(alu_out),
        .zero(zero),
        .negative(negative),
        .overflow(overflow)
    );

    Random_sel rand_sel = new();
    Random_Num #(WIDTH) rand_a = new();
    Random_Num #(WIDTH) rand_b = new();

    initial begin
        $dumpfile("waveform.vcd"); $dumpvars(0, full_adder_tb);

        repeat(5) begin
            #10
            a <= rand_a; b <= rand_b ;alu_sel <= rand_sel.num; 
            rand_a.randomize();
            rand_b.randomize();
            rand_sel.randomize();
        end
    end
    
endmodule