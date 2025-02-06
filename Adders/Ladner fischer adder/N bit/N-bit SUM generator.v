module N_bit_SUMgenerator#(parameter N = 64 )// Parameter for data width, default is 64
  (
    input wire [N-1:0] c, p, // Input wires for c and p of configurable width
    output wire [N-1:0] s    // Output wire for s (sum) of configurable width
  );
  
  // XOR operation between c and p, assigning the result to s
  assign s = c ^ p; // 's' will be the bitwise XOR of c and p

endmodule


module N_bit_SUMgenerator_tb;

  // Parameter for the data width
  parameter N = 64;

  // Inputs to the module (reg for testbench)
  reg [N-1:0] c, p;

  // Outputs from the module (wire for testbench)
  wire [N-1:0] s;

  // Instantiate the Unit Under Test (UUT)
  N_bit_SUMgenerator #(.N(N)) uut (c, p, s);

  // Monitor output changes
  initial begin
    $monitor("Time = %0dns | c = %h | p = %h | s = %h", $time, c, p, s);
  end

  // Test process
  initial begin
    // Apply test vectors with some delay
    c = {N{1'b1}}; p = {N{1'b0}}; #10; // All 1s XOR All 0s
    c = {N{1'b0}}; p = {N{1'b1}}; #10; // All 0s XOR All 1s
    c = {N{1'b1}}; p = {N{1'b1}}; #10; // All 1s XOR All 1s
    c = 64'hAAAAAAAAAAAAAAAA; p = 64'h5555555555555555; #10; // Alternating bits
    c = 64'h123456789ABCDEF0; p = 64'hFEDCBA9876543210; #10; // Random pattern
    c = {N{1'b0}}; p = {N{1'b0}}; #10; // All 0s XOR All 0s

    // End simulation
    $stop;
  end

endmodule
