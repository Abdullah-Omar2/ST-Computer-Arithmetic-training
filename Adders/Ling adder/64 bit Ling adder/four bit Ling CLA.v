module four_bit_Ling_CLA
  (
  input wire cin,                // Carry input (cin)
  input wire [3:0] p,            // Propagate signals (p)
  input wire [3:0] g,            // Generate signals (g)
  output wire [4:1] h,           // Carry signals (h) for each bit
  output wire P,                 // Block propagate signal for the 4-bit group
  output wire G                  // Block generate signal for the 4-bit group
  );

  wire [3:0] t; // Intermediate signal combining generate and propagate

  // Compute the block propagate signal (P) for the entire 4-bit group
  assign P = &p;  // P is the AND of all propagate bits

  // Compute the block generate signal (G) for the entire 4-bit group
  assign G = g[3] | (g[2] & p[3]) | (g[1] & &p[3:2]) | (g[0] & &p[3:1]);

  // Compute the combined transfer signal (t)
  assign t = g | p;

  // Compute individual carry (h) signals using Ling's carry equations
  assign h[1] = g[0] | cin;               // Carry for bit 1
  assign h[2] = g[1] | (t[0] & h[1]);     // Carry for bit 2
  assign h[3] = g[2] | (t[1] & h[2]);     // Carry for bit 3
  assign h[4] = g[3] | (t[2] & h[3]);     // Carry for bit 4 (final carry output)

endmodule
