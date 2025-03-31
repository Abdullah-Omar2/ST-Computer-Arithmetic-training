`define default_NAN {8'hff, 23'd1}  // Default NaN representation
`define default_infinity {8'hff, 23'd0}  // Default Infinity representation

// Module to pack floating-point components into IEEE 754 format
module pack (
  input sign,                // Sign bit of the result
  input [7:0] exp,           // Exponent of the result
  input [22:0] sig,          // Significand of the result
  input a_zero,              // Flag indicating if operand A is zero
  input a_infinity,          // Flag indicating if operand A is infinity
  input a_NAN,               // Flag indicating if operand A is NaN
  input b_zero,              // Flag indicating if operand B is zero
  input b_infinity,          // Flag indicating if operand B is infinity
  input b_NAN,               // Flag indicating if operand B is NaN
  output [31:0] flp_div      // Packed IEEE 754 floating-point result
);

  // Assign appropriate result based on special cases
  assign flp_div = (a_NAN | b_NAN | b_zero | (a_infinity & b_infinity)) ? {sign, `default_NAN} :  // NaN cases
                   (a_infinity) ? {sign, `default_infinity} :                                      // Infinity case
                   (a_zero | b_infinity) ? 32'b0 :                                                // Zero result case
                   {sign, exp, sig};                                                              // Normal case

endmodule
