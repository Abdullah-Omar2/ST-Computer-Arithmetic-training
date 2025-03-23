module exponent_handling (
  input [7:0] exp_a, exp_b,
  input adjustment,
  output [7:0] exp_div
  );
  
  assign exp_div = exp_a - exp_b + 127 - adjustment;
  
endmodule
