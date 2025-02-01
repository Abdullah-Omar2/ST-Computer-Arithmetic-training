module N_bit_SUMgenerator#(parameter N = 64 )// Parameter for data width, default is 64
  (
    input wire [N-1:0] h, p, g, // Input wires for c and p of configurable width
    output wire [N-1:0] s    // Output wire for s (sum) of configurable width
  );
  
  // Compute the least significant bit of the sum using XOR operation
  assign s[0] = h[0] ^ p[0];  

  genvar i;
  generate
    for (i = 1; i < N; i = i + 1) begin : a
      // Compute each sum bit using a combination of propagate, generate, and history terms
      assign s[i] = p[i] ^ (h[i] & (p[i-1] | g[i-1]));
    end
  endgenerate


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
