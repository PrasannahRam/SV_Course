module full_adder (
    input  logic a, b, ci,
    output logic sum, co
);

    logic wire_1, wire_2;

    assign wire_1 = a ^ b;       // bitwise XOR
    assign wire_2 = wire_1 & ci; // bitwise AND

    wire wire_3 = a & b;         // bitwise AND

    always_comb begin
        co  = wire_2 | wire_3;   // bitwise OR
        sum = wire_1 ^ ci ;      // bitwise XOR
    end

endmodule

// logic wire_1  , wire wire_3 = a & b; , always_comb begin these 3 methodes are used to
// assign the ports. all there methods are equevelent
//
// assign Vs always_comb
// assign
//    ↓
// "wire this expression to this signal"

// always_comb
//    ↓
// "describe the steps needed to calculate this signal"