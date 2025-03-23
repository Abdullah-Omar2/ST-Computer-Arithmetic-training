module unpack (
  input [31:0] flp_a,
  input [31:0] flp_b,
  output sign_a,
  output [7:0] exp_a,
  output [22:0] sig_a,
  output sign_b,
  output [7:0] exp_b,
  output [22:0] sig_b,
  output a_zero,
  output a_infinity,
  output a_NAN,
  output b_zero,
  output b_infinity,
  output b_NAN
  );
  
  assign sign_a = flp_a[31];
  
  assign exp_a = flp_a[30:23];
  
  assign sig_a = flp_a[22:0];
  
  assign sign_b = flp_b[31];
  
  assign exp_b = flp_b[30:23];
  
  assign sig_b = flp_b[22:0];
  
  assign a_zero = (exp_a == 8'b00000000) && (sig_a == 0);
  
  assign a_infinity = (exp_a == 8'b11111111) && (sig_a == 0);
  
  assign a_NAN = (exp_a == 8'b11111111) && (sig_a != 0);
  
  assign b_zero = (exp_b == 8'b00000000) && (sig_b == 0);
  
  assign b_infinity = (exp_b == 8'b11111111) && (sig_b == 0);
  
  assign b_NAN = (exp_b == 8'b11111111) && (sig_b != 0);
  
endmodule
