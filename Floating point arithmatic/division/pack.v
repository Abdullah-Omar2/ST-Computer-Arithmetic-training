`define default_NAN {8'hff, 23'd1}
`define default_infinity {8'hff, 23'd0}

module pack (
  input sign,
  input [7:0] exp,
  input [22:0] sig,
  input a_zero,
  input a_infinity,
  input a_NAN,
  input b_zero,
  input b_infinity,
  input b_NAN,
  output [31:0] flp_div
);

  assign flp_div = (a_NAN | b_NAN | b_zero | (a_infinity & b_infinity)) ? {sign, `default_NAN} :
                   (a_infinity) ? {sign, `default_infinity} :
                   (a_zero) ? 32'b0 :
                   {sign, exp, sig};

endmodule
