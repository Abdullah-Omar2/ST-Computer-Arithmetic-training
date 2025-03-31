 module Normalize (
  input [23:0] quotient,     // Input quotient from division
  output [23:0] normalized,  // Normalized quotient
  output adjustment          // Indicates whether an adjustment is needed
);

  // If the MSB of quotient is 1, it's already normalized.
  // Otherwise, shift left by one position to normalize.
  assign normalized = quotient[23] ? quotient : (quotient << 1);

  // Adjustment flag is set if normalization required (i.e., quotient's MSB is 0)
  assign adjustment = quotient[23] ? 1'b0 : 1'b1;

endmodule 