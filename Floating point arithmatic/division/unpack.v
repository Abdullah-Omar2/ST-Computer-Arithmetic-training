module unpack (
  input  [31:0] flp_a, // 32-bit IEEE 754 floating-point number A
  input  [31:0] flp_b, // 32-bit IEEE 754 floating-point number B
  output        sign_a,  // Sign bit of A
  output [7:0]  exp_a,   // Exponent part of A
  output [22:0] sig_a,   // Significand (mantissa) of A
  output        sign_b,  // Sign bit of B
  output [7:0]  exp_b,   // Exponent part of B
  output [22:0] sig_b,   // Significand (mantissa) of B
  output        a_zero,      // A is zero
  output        a_infinity,  // A is infinity
  output        a_NAN,       // A is NaN (Not a Number)
  output        b_zero,      // B is zero
  output        b_infinity,  // B is infinity
  output        b_NAN        // B is NaN (Not a Number)
);

// Extract sign bit, exponent, and significand from A
assign sign_a = flp_a[31];         // Sign bit is the MSB (bit 31)
assign exp_a  = flp_a[30:23];      // Exponent is bits 30 to 23
assign sig_a  = flp_a[22:0];       // Significand is bits 22 to 0

// Extract sign bit, exponent, and significand from B
assign sign_b = flp_b[31];         // Sign bit is the MSB (bit 31)
assign exp_b  = flp_b[30:23];      // Exponent is bits 30 to 23
assign sig_b  = flp_b[22:0];       // Significand is bits 22 to 0

// Check special cases for A
assign a_zero     = (exp_a == 8'b00000000) && (sig_a == 0); // Zero if exponent and significand are zero
assign a_infinity = (exp_a == 8'b11111111) && (sig_a == 0); // Infinity if exponent is all 1s and significand is zero
assign a_NAN      = (exp_a == 8'b11111111) && (sig_a != 0); // NaN if exponent is all 1s and significand is non-zero

// Check special cases for B
assign b_zero     = (exp_b == 8'b00000000) && (sig_b == 0);
assign b_infinity = (exp_b == 8'b11111111) && (sig_b == 0);
assign b_NAN      = (exp_b == 8'b11111111) && (sig_b != 0);

endmodule
