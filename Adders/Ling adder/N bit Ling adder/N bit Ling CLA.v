module N_bit_Ling_CLA #(parameter integer N = 64)(
  input wire cin,             // Carry-in input (initial carry value)
  input wire [N-1:0] p, g,    // 64-bit propagate (p) and generate (g) signals
  output wire [N:1] h         // 64-bit carry signals (h), with h[N] as the final carry-out
);
  wire [N-1:0] t;            // Intermediate wire to store the OR of propagate and generate signals
  assign t = p | g;          // Propagate or generate signal for each bit position
  
  assign h[1] = g[0] | cin;  // First carry-out (h[1]) depends on the first generate signal (g[0]) and carry-in (cin)
 
  genvar i;
  generate
    for (i = 2; i < N+1; i = i + 1) begin : b
      // Generate the carry signals using the Ling method: h[i] = g[i-1] | (t[i-2] & h[i-1])
      assign h[i] = g[i-1] | (t[i-2] & h[i-1]);
    end
  endgenerate

endmodule
