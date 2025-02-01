module SUMgenerator
  (
  input wire [63:0] h, p, g,  // 64-bit input wires for h, p, and g
  output wire [63:0] s        // 64-bit output wire for sum (s)
  );
  
  // Compute the least significant bit of the sum using XOR operation
  assign s[0] = h[0] ^ p[0];  

  genvar i;
  generate
    for (i = 1; i < 64; i = i + 1) begin : a
      // Compute each sum bit using a combination of propagate, generate, and history terms
      assign s[i] = p[i] ^ (h[i] & (p[i-1] | g[i-1]));
    end
  endgenerate

endmodule

