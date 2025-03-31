module exponent_handling (
  input [7:0] exp_a, exp_b,  // Input exponents of the floating-point numbers
  input adjustment,          // Adjustment bit from normalization step
  output [7:0] exp_div       // Computed exponent for the division result
);

  // Compute the exponent of the result:
  // exp_div = exp_a - exp_b + bias (127) - adjustment
  assign exp_div = exp_a - exp_b + 127 - adjustment;

endmodule
