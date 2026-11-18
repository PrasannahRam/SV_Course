timeunit 10ns;timeprecision 1ns;

module full_adder_tb;

    logic a=0,ci=0,b,sum,co;          // Inputs and outputs declaration

    // Design Under Test
    // full_adder dut (         //same as c++ object declaration
    //     .a  (a),
    //     .b  (b),
    //     .ci (ci),
    //     .sum(sum),
    //     .co (co)
    // );

    full_adder dut (.*); // declaring all ports with .* is equivalent to the above commented code

    // Initial block 1   //there can be multiple blocks. all of them will be running parralely
    initial begin

        $dumpfile("waveform.vcd"); $dumpvars(0, full_adder_tb);
        //recording the simulation activity into a VCD waveform file, which you can later open in GTKWave.

        #30 a = 0; b = 0; ci = 0; // driving the inputs after 30 x 10ns = 300ns
        #10 a = 0; b = 0; ci = 1;

        #20 a = 1; b = 1; ci = 0;

        #10 a = 1; b = 1; ci = 1;

        // Instead of checking the result manually we define testbench to check the result automatically
        // #1 label: assert (dut.wire_1 == 0)           //warns only at contradictions(dont tell true cases)
        //     else $error("Assertion label failed!");

        #1 assert ({co,sum} == a+b+ci)              //warns at both true and false cases
        $display ("Ok");                            //{co,cin} is concatenation of 2 bit --> 1vector
            else $error("Addintion failed %d + %d + %d = %d%d", a, b, ci, co, sum);

        $finish();
    end

endmodule

// in the wave form you will see that summ and b are in red color. means they are not driven until 30ns.
// wire and logic are called 4 state variables. they can be 0,1,x,z. x means unknown(inputs) and z means high impedance(outputs).