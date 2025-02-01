module N_bit_GPgeneration #(parameter N = 64) (
  input wire [N-1:0] a, b,    // Generic input operands a and b
  output wire [N-1:0] p, g    // Generic outputs p (propagate) and g (generate)
);
  assign p = a ^ b;               // Propagate: XOR operation
  assign g = a & b;               // Generate: AND operation
endmodule


module N_bit_GPgeneration_tb;

  parameter N = 64;             // Parameterized bit-width for the testbench
  reg [N-1:0] a, b;            // Generic registers to hold test inputs
  wire [N-1:0] p, g;           // Generic wires to observe the outputs of the module

  // Instantiate the N_bit_GPgeneration module as Unit Under Test (UUT)
  N_bit_GPgeneration #(N) uut (
    .a(a),
    .b(b),
    .p(p),
    .g(g)
  );

  initial begin
    // $monitor monitors the values of specified signals and displays 
    // them whenever any of the signals change.
    $monitor("Time: %0t | a: %b | b: %b | p: %b | g: %b", $time, a, b, p, g);

    // Test Case 1: All bits of a are 1, all bits of b are 0
    a = 64'hFFFFFFFFFFFFFFFF; 
    b = 64'h0000000000000000; 
    #10;  // Wait for 10 time units

    // Test Case 2: Alternating bits in a and b
    a = 64'hAAAAAAAAAAAAAAAA; 
    b = 64'h5555555555555555; 
    #10; 

    // Test Case 3: Arbitrary values in a and b
    a = 64'h123456789ABCDEF0; 
    b = 64'h0FEDCBA987654321; 
    #10;

    // Test Case 4: All bits of b are 1, all bits of a are 0
    a = 64'h0000000000000000; 
    b = 64'hFFFFFFFFFFFFFFFF; 
    #10; 

    // Test Case 5: High and low bits of a and b are inverted
    a = 64'hFFFFFFFF00000000; 
    b = 64'h00000000FFFFFFFF; 
    #10; 

    // Test Case 6: Randomized pattern in a and b
    a = 64'h1234567812345678; 
    b = 64'h8765432187654321; 
    #10;

    // Stop the simulation
    $stop;
  end

endmodule

