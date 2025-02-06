module SUMgenerator
  (
  input wire [63:0] c, p,  // 64-bit input wires for c and p
  output wire [63:0] s     // 64-bit output wire for s (sum)
  );
  
  // XOR operation between c and p, assigning the result to s
  assign s = c ^ p;        // 's' will be the bitwise XOR of c and p

endmodule



module SUMgenerator_tb;

  // Inputs to the module (reg for testbench)
  reg [63:0] c, p;

  // Outputs from the module (wire for testbench)
  wire [63:0] s;

  // Instantiate the Unit Under Test (UUT)
  SUMgenerator uut (c,p,s);

  // Monitor output changes
  initial begin
    // Display the header for results
    $monitor("Time = %0dns | c = %d | p = %d | s = %d", $time, c, p, s);
  end

  // Test process
  initial begin
    // Apply test vectors with some delay
    c = 64'd29; p = 64'd5; #10; // All 1s XOR All 0s
    c = 64'hAAAAAAAAAAAAAAAA; p = 64'h5555555555555555; #10; // Alternating bits
    c = 64'h123456789ABCDEF0; p = 64'hFEDCBA9876543210; #10; // Random pattern
    c = 64'h0000000000000000; p = 64'hFFFFFFFFFFFFFFFF; #10; // All 0s XOR All 1s
    c = 64'h0000000000000000; p = 64'h0000000000000000; #10; // All 0s XOR All 0s

    // End simulation
    $stop;
  end

endmodule