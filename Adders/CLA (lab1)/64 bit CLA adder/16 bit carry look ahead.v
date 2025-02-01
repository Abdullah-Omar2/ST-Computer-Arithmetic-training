module _16_bit_carry_look_ahead 
  (
  input wire cin,            // Carry input from previous stage (or 0 for the first stage)
  input wire [15:0] p,       // Propagate signal array (p[15:0])
  input wire [15:0] g,       // Generate signal array (g[15:0])
  output wire [16:1] c,      // Carry output array (c[16:1])
  output wire P,             // Final propagate output
  output wire G              // Final generate output
  );
  
  // Internal wires for 4-bit carry look-ahead logic
  wire [3:0] Pin, Gin;       // Propagate and generate for each 4-bit CLA block
  wire [4:1] c_bet;          // Carry between different 4-bit CLA blocks

  // 4-bit Carry Look-Ahead Adders (CLA) for each 4-bit chunk of the 16-bit input
  // Each CLA generates its carry outputs (c[3:1], c[7:5], c[11:9], c[15:13])
  four_bit_carry_look_ahead cla1 (cin, p[3:0], g[3:0], c[3:1], Pin[0], Gin[0]);
  four_bit_carry_look_ahead cla2 (c_bet[1], p[7:4], g[7:4], c[7:5], Pin[1], Gin[1]);
  four_bit_carry_look_ahead cla3 (c_bet[2], p[11:8], g[11:8], c[11:9], Pin[2], Gin[2]);
  four_bit_carry_look_ahead cla4 (c_bet[3], p[15:12], g[15:12], c[15:13], Pin[3], Gin[3]);

  // Final 4-bit CLA that connects the carries between stages and outputs the final P and G
  four_bit_carry_look_ahead cla5 (cin, Pin, Gin, c_bet, P, G);

  // Assign carry outputs for each 4-bit segment
  assign c[4] = c_bet[1];
  assign c[8] = c_bet[2];
  assign c[12] = c_bet[3];
  assign c[16] = c_bet[4];

endmodule


// Testbench for 16-bit Carry Look-Ahead Adder
module _16_bit_carry_look_ahead_tb;

  // Declare input signals
  reg cin;                   // Carry input
  reg [15:0] p;               // Propagate input
  reg [15:0] g;               // Generate input

  // Declare output signals
  wire [16:1] c;              // Carry output
  wire P, G;                  // Final propagate and generate outputs

  // Instantiate the 16-bit Carry Look-Ahead Adder
  _16_bit_carry_look_ahead uut (cin, p, g, c, P, G);

  // Test vector generation
  initial begin
    
    // Initial test case with all inputs set to 0
    cin = 0;
    p = 16'b0000000000000000;  // Propagate: 0
    g = 16'b0000000000000000;  // Generate: 0

    // Monitor changes in signals
    $monitor("Time: %0t | cin: %b | p: %b | g: %b | c: %b | P: %b | G: %b", $time, cin, p, g, c, P, G);

    // Test case 1: Some propagate and generate values
    #5 p = 16'b1010101010101010; g = 16'b0101010101010101; cin = 0;
    // Test case 2: All propagate are 1, generate are 0
    #10 p = 16'b1111111111111111; g = 16'b0000000000000000; cin = 1;
    // Test case 3: Mixed propagate and generate values
    #15 p = 16'b1100110011001100; g = 16'b1010101010101010; cin = 0;
    // Test case 4: All generate are 1, propagate are 0
    #20 p = 16'b0000000000000000; g = 16'b1111111111111111; cin = 1;

    // Finish the simulation after all test cases
    #25 $finish;
    
  end

endmodule

