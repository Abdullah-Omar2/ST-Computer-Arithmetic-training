module _16_bit_Ling_CLA 
  (
  input wire cin,            // Carry input from the previous stage (0 for the first stage)
  input wire [15:0] p,       // Propagate signal array (p[15:0])
  input wire [15:0] g,       // Generate signal array (g[15:0])
  output wire [16:1] h,      // Carry output array (h[16:1])
  output wire P,             // Final block propagate output
  output wire G              // Final block generate output
  );

  // Internal wires for 4-bit carry look-ahead logic
  wire [3:0] Pin, Gin;       // Propagate and generate for each 4-bit CLA block
  wire [4:1] h_bet;          // Carry signals between 4-bit CLA blocks

  // Instantiate four 4-bit CLA modules to process 16-bit segments
  four_bit_Ling_CLA lcla1 (cin, p[3:0], g[3:0], h[3:1], Pin[0], Gin[0]);
  four_bit_Ling_CLA lcla2 ((h_bet[1] & (p[3] | g[3])), p[7:4], g[7:4], h[7:5], Pin[1], Gin[1]);
  four_bit_Ling_CLA lcla3 ((h_bet[2] & (p[7] | g[7])), p[11:8], g[11:8], h[11:9], Pin[2], Gin[2]);
  four_bit_Ling_CLA lcla4 ((h_bet[3] & (p[11] | g[11])), p[15:12], g[15:12], h[15:13], Pin[3], Gin[3]);

  // Compute the final carry propagation and generation using another 4-bit CLA
  four_bit_Ling_CLA lcla5 (cin, Pin, Gin, h_bet, P, G);

  // Assign carry outputs for each 4-bit segment
  assign h[4]  = h_bet[1];
  assign h[8]  = h_bet[2];
  assign h[12] = h_bet[3];
  assign h[16] = h_bet[4];

endmodule
