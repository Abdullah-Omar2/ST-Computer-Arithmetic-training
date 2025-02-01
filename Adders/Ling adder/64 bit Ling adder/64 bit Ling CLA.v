module _64_bit_Ling_CLA 
  (
  input wire cin,                // Input carry bit (cin)
  input wire [63:0] p, g,        // Propagate (p) and Generate (g) signals for 64 bits
  output wire [64:1] h,          // Carry (h) signals for 64 bits
  output wire P, G               // Overall propagate (P) and generate (G) signals for 64 bits
  );

  // Internal signals for the 16-bit CLA modules
  wire [3:0] Pin, Gin;           // Propagate and generate signals for 4 segments
  wire [4:1] h_bet;              // Internal carry signals between 16-bit CLAs
  
  // Instantiate four 16-bit Ling Carry Look-Ahead Adders (CLA)
  // Each CLA processes a 16-bit segment of the 64-bit propagate and generate signals
  _16_bit_Ling_CLA lcla1 (cin, p[15:0], g[15:0], h[15:1], Pin[0], Gin[0]);
  _16_bit_Ling_CLA lcla2 ((h_bet[1] & (p[15] | g[15])), p[31:16], g[31:16], h[31:17], Pin[1], Gin[1]);
  _16_bit_Ling_CLA lcla3 ((h_bet[2] & (p[31] | g[31])), p[47:32], g[47:32], h[47:33], Pin[2], Gin[2]);
  _16_bit_Ling_CLA lcla4 ((h_bet[3] & (p[47] | g[47])), p[63:48], g[63:48], h[63:49], Pin[3], Gin[3]);

  // Instantiate a 4-bit Ling CLA to handle the carry signals between the 16-bit CLAs
  four_bit_Ling_CLA cla5 (cin, Pin, Gin, h_bet, P, G);
  
  // Assign the intermediate carry signals to the final 64-bit carry array
  assign h[16] = h_bet[1];  // Carry bit from the first 16-bit CLA
  assign h[32] = h_bet[2];  // Carry bit from the second 16-bit CLA
  assign h[48] = h_bet[3];  // Carry bit from the third 16-bit CLA
  assign h[64] = h_bet[4];  // Carry bit from the fourth 16-bit CLA
    
endmodule
