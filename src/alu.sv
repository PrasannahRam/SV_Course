module alu #(
    parameter WIDTH = 8,
            W_ALU_SEL = 3
) (
    input  logic signed [WIDTH-1:0] a, b,       // for signed operations
    input  logic [W_ALU_SEL-1:0] alu_sel,
    output logic signed [WIDTH-1:0] alu_out,
    output logic zero, negative, overflow             // flags

);
    logic signed [2*WIDTH-1:0] product;
    always_comb begin

    overflow = (alu_sel == 3'b000) ? (a[WIDTH-1] == b[WIDTH-1]) && (alu_out[WIDTH-1] != a[WIDTH-1]) : 1'b0;
    if (alu_sel == 3'b000) alu_out = a + b ;
    else if (alu_sel == 3'b001) alu_out = a - b;
    else if (alu_sel == 3'b010) begin
        product = a * b;
        alu_out = product[WIDTH-1:0];
        overflow = (product[2*WIDTH-1:WIDTH] != {WIDTH{alu_out[WIDTH-1]}});
    end
    else if (alu_sel == 3'b011) alu_out = a / 2; 
    else alu_out = a;
    
    zero = (alu_out == 0);
    negative = (alu_out < 0);

    end

endmodule

//HOW DOES MULTIPILIER OVERFLOW WORK?
//Here:
// - product stores the full multiplication result.
// - alu_out stores only the lower N bits.
// - product[N-1] is the sign bit of the truncated result.
// - {N{product[N-1]}} replicates the sign bit N times.
// - If the upper bits don't match the expected sign extension, overflow occurred.