module _64_bit_carry_look_ahead 
  (
  input wire cin,                // Input carry bit (cin)
  input wire [63:0] p,g,         // Propagate (p) and generate (g) signals for 64 bits
  output wire [64:1] c,          // Carry output for 64 bits
  output wire P, G               // Overall propagate (P) and generate (G) signals
  );

  // Internal wires for 16-bit CLA modules
  wire [3:0] Pin, Gin;           // Internal propagate and generate for the 4 segments
  wire [4:1] c_bet;              // Internal carry bits between 16-bit CLAs
  
  // Instantiate four 16-bit Carry Look-Ahead Adders (CLA)
  // Each CLA processes a 16-bit segment of the 64-bit propagate and generate signals
  _16_bit_carry_look_ahead cla1 (cin, p[15:0], g[15:0], c[15:1], Pin[0], Gin[0]);
  _16_bit_carry_look_ahead cla2 (c_bet[1], p[31:16], g[31:16], c[31:17], Pin[1], Gin[1]);
  _16_bit_carry_look_ahead cla3 (c_bet[2], p[47:32], g[47:32], c[47:33], Pin[2], Gin[2]);
  _16_bit_carry_look_ahead cla4 (c_bet[3], p[63:48], g[63:48], c[63:49], Pin[3], Gin[3]);

  // Instantiate a 4-bit CLA to handle the carries between the 16-bit CLAs
  four_bit_carry_look_ahead cla5 (cin, Pin, Gin, c_bet, P, G);
  
  // Assign the carry bits from the 4-bit CLA to the final carry array for 64 bits
  assign c[16] = c_bet[1];  // Carry bit from first 16-bit CLA
  assign c[32] = c_bet[2];  // Carry bit from second 16-bit CLA
  assign c[48] = c_bet[3];  // Carry bit from third 16-bit CLA
  assign c[64] = c_bet[4];  // Carry bit from fourth 16-bit CLA
    
endmodule




module _64_bit_carry_look_ahead_tb;

  reg cin;
  reg [63:0] p;
  reg [63:0] g;
  wire [64:1] c;
  wire P;
  wire G;

  _64_bit_carry_look_ahead uut (cin,p,g,c,P,G);

  // Task to calculate expected results
  task calculate_carry;
    input [63:0] p_in, g_in;
    input c_in;
    output [64:1] c_out;
    integer i;
    begin
      c_out[1] = g_in[0] | (p_in[0] & c_in);  // First carry
      for (i = 1; i < 64; i = i + 1) begin
        c_out[i + 1] = g_in[i] | (p_in[i] & c_out[i]);
      end
    end
  endtask

  // Simulation variables
  reg [64:1] expected_c;

  // Testbench logic
  initial begin
    // Monitor outputs
    $monitor("Time=%0t | cin=%b | p=%h | g=%h | c=%h | P=%b | G=%b", 
             $time, cin, p, g, c, P, G);

    // Test Case 1: All propagate and no generate
    cin = 0;
    p = 64'hFFFFFFFFFFFFFFFF;  // All propagate
    g = 64'h0;                // No generate
    #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 1!");

    // Test Case 2: Mixed propagate and generate
    cin = 1;
    p = 64'hAA55AA55AA55AA55; // Alternate propagate
    g = 64'h55AA55AA55AA55AA; // Alternate generate
    #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 2!");

    // Test Case 3: All generate
    cin = 0;
    p = 64'h0;                // No propagate
    g = 64'hFFFFFFFFFFFFFFFF; // All generate
    #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 3!");

    // Test Case 4: All zeros
    cin = 0;
    p = 64'h0;  // No propagate
    g = 64'h0;  // No generate
    #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 4!");

    // Test Case 5: Random inputs
    cin = 1;
    p = $random;
    g = $random;
    #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 5!");

    // End simulation
    $stop;
  end

endmodule


