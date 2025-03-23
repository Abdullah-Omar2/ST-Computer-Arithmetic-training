module FLP_divider (
  input clk, rst,
  input [31:0] a, b,
  output [31:0] q,
  output done
  );
  
  wire sign_a, sign_b;
  wire [7:0] exp_a, exp_b;
  wire [22:0] sig_a, sig_b;
  
  wire a_zero, a_infinity, a_NAN;
  wire b_zero, b_infinity, b_NAN;
  
  unpack up (
  .flp_a(a),
  .flp_b(b),
  .sign_a(sign_a),
  .exp_a(exp_a),
  .sig_a(sig_a),
  .sign_b(sign_b),
  .exp_b(exp_b),
  .sig_b(sig_b),
  .a_zero(a_zero),
  .a_infinity(a_infinity),
  .a_NAN(a_NAN),
  .b_zero(b_zero),
  .b_infinity(b_infinity),
  .b_NAN(b_NAN)
  );
  
  wire sign_res;
  
  sign_handling sh (
  .sign_a(sign_a),
  .sign_b(sign_b),
  .sign_res(sign_res)
  );
  
  wire [23:0] Divider_res;
  
  Divider #(24) div (
  .clk(clk),
  .rst(rst),
  .dividend({1'b1,sig_a}),
  .divisor({1'b1,sig_b}),
  .quotient(Divider_res),
  .remainder(),
  .done(done)
  );
  
  wire [23:0] Normalize_res;
  wire adjustment;
  
  Normalize Norm(
  .quotient(Divider_res),
  .normalized(Normalize_res),
  .adjustment(adjustment)
  );
  
  wire [7:0] exp_res;
  
  exponent_handling eh (
  .exp_a(exp_a),
  .exp_b(exp_b),
  .adjustment(adjustment),
  .exp_div(exp_res)
  );
  
  
  pack p (
  .sign(sign_res),
  .exp(exp_res),
  .sig(Normalize_res[22:0]),
  .a_zero(a_zero),
  .a_infinity(a_infinity),
  .a_NAN(a_NAN),
  .b_zero(b_zero),
  .b_infinity(b_infinity),
  .b_NAN(b_NAN),
  .flp_div(q)
  );

endmodule




`timescale 1ns/1ps
module tb_FLP_divider;

  reg clk;
  reg rst;
  reg [31:0] a;
  reg [31:0] b;
  wire [31:0] q;
  wire done;
  
  // Instantiate the FLP_divider module
  FLP_divider uut (
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .q(q),
    .done(done)
  );
  
  // Clock generation: period = 10ns
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Test vector application
  initial begin
    rst=1;
    a=32'b0_10000001_01110000000000000000000;
    b=32'b1_10000000_01000000000000000000000;
    #10;
    rst=0;
    #10;
    wait(done);
    #10;
    
    $display("Time=%0t | %f / %f = %f", $time,(-1.0)**a[31] * (1.0 + a[22:0] / (2.0**23)) * (2.0**(a[30:23] - 127))
                                             ,(-1.0)**b[31] * (1.0 + b[22:0] / (2.0**23)) * (2.0**(b[30:23] - 127))
                                             ,(-1.0)**q[31] * (1.0 + q[22:0] / (2.0**23)) * (2.0**(q[30:23] - 127)));
    
    $stop;
  end

endmodule
