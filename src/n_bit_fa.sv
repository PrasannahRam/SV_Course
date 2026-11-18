module n_bit_fa #( parameter N=8) (
    input logic [N-1:0] a, b,
    input logic ci,
    output logic [N-1:0] sum,
    output logic co
);
wire [N-1:0] co_wire;
genvar i;
for (i = 0; i < N; i++) begin
    full_adder fa (
        .a(a[i]),
        .b(b[i]),
        .ci(i==0 ? ci : co_wire[i-1]),
        .sum(sum[i]),
        .co(co_wire[i])
    );
    
end
assign co = co_wire[N-1];
    
endmodule