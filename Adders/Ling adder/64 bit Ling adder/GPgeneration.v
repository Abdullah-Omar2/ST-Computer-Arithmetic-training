module GPgeneration (
  input wire [63:0] a, b,    // 64-bit input operands a and b
  output wire [63:0] g, p    // 64-bit outputs g (generate) and p (propagate)
);

  // Generate signal: Identifies where both bits are '1' (carry generation)
  assign g = a & b;          

  // Propagate signal: Identifies where at least one bit is '1' (carry propagation)
  assign p = a ^ b;

endmodule
