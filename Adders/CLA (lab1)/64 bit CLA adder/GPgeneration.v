module GPgeneration (
  input wire [63:0] a, b,    // 64-bit input operands a and b
  output wire [63:0] p, g    // 64-bit outputs p (propagate) and g (generate)
);
  assign p = a ^ b;          // Propagate: XOR operation
  assign g = a & b;          // Generate: AND operation
endmodule


// Testbench: GPgeneration_tb
// Description: This testbench verifies the functionality of the GPgeneration module 
// by providing various test cases and displaying the outputs.

module GPgeneration_tb;

  reg [63:0] a, b;           // 64-bit registers to hold test inputs
  wire [63:0] p, g;          // 64-bit wires to observe outputs of the module

  // Instantiate the GPgeneration module as Unit Under Test (UUT)
  GPgeneration uut (a, b, p, g);

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
