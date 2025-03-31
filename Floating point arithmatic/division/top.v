module FLP_divider (
  input clk, rst, // Clock and Reset Signals
  input [31:0] a, b, // Floating-point inputs
  output [31:0] q, // Floating-point quotient output
  output done // Done signal to indicate completion
  );
  
  // Wires for unpacking floating-point numbers
  wire sign_a, sign_b;
  wire [7:0] exp_a, exp_b;
  wire [22:0] sig_a, sig_b;
  
  // Wires to identify special cases (Zero, Infinity, NaN)
  wire a_zero, a_infinity, a_NAN;
  wire b_zero, b_infinity, b_NAN;
  
  // Unpack module extracts sign, exponent, and significand from inputs
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
  
  wire sign_res; // Sign of the result
  
  // Module to handle sign computation of result
  sign_handling sh (
  .sign_a(sign_a),
  .sign_b(sign_b),
  .sign_res(sign_res)
  );
  
  wire [23:0] Divider_res; // Stores division result
  
  // Divider module for floating-point division
  Divider #(47) div (
  .clk(clk),
  .rst(rst),
  .dividend({1'b1,sig_a,23'b0}), // Normalize dividend
  .divisor({23'b0,1'b1,sig_b}), // Normalize divisor
  .quotient(Divider_res), // Output quotient
  .remainder(), // Remainder (not used)
  .done(done) // Done signal
  );
  
  wire [23:0] Normalize_res; // Stores normalized quotient
  wire adjustment; // Adjustment signal for exponent
  
  // Module to normalize the quotient
  Normalize Norm(
  .quotient(Divider_res),
  .normalized(Normalize_res),
  .adjustment(adjustment)
  );
  
  wire [7:0] exp_res; // Exponent result after handling
  
  // Module to compute exponent for the result
  exponent_handling eh (
  .exp_a(exp_a),
  .exp_b(exp_b),
  .adjustment(adjustment),
  .exp_div(exp_res)
  );
  
  // Module to pack the final result back into IEEE 754 format
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
  
  // Test vector application covering all cases:
  initial begin

    rst = 1;
    a = 32'b0_10000011_01000000000000000000000; // Example values
    b = 32'b0_10000001_00000000000000000000000;
    #10; rst = 0; #10; wait(done); #10;
    print_fp(a); print_fp(b); print_fp(q);
    
    // Division by Zero
    rst = 1;
    a = 32'b0_10000010_00000000000000000000000; 
    b = 32'b0_00000000_00000000000000000000000;
    #10; rst = 0; #10; wait(done); #10;
    print_fp(a); print_fp(b); print_fp(q);
    
    // Zero divided by a number
    rst = 1;
    a = 32'b0_00000000_00000000000000000000000;
    b = 32'b0_10000010_00000000000000000000000;
    #10; rst = 0; #10; wait(done); #10;
    print_fp(a); print_fp(b); print_fp(q);
    
    // Negative number division
    rst = 1;
    a = 32'b1_10000011_01000000000000000000000;
    b = 32'b0_10000001_00000000000000000000000; 
    #10; rst = 0; #10; wait(done); #10;
    print_fp(a); print_fp(b); print_fp(q);
    
    // Infinity case
    rst = 1;
    a = 32'b0_11111111_00000000000000000000000;
    b = 32'b0_10000010_00000000000000000000000; 
    #10; rst = 0; #10; wait(done); #10;
    print_fp(a); print_fp(b); print_fp(q);
    
    // NaN case
    rst = 1;
    a = 32'b0_11111111_10000000000000000000000;
    b = 32'b0_10000010_00000000000000000000000;
    #10; rst = 0; #10; wait(done); #10;
    print_fp(a); print_fp(b); print_fp(q);
    
    // Large number divided by small number
    rst = 1;
    a = 32'b0_10011111_00000000000000000000000;
    b = 32'b0_00000001_00000000000000000000000;
    #10; rst = 0; #10; wait(done); #10;
    print_fp(a); print_fp(b); print_fp(q);
    
    // Random test cases
    repeat(10) begin
      rst = 1;
      a = $random;
      b = $random;
      #10; rst = 0; #10; wait(done); #10;
      print_fp(a); print_fp(b); print_fp(q);
    end
    
    $stop;
  end
  
  task print_fp(input [31:0] float_num);
        real result, fraction_part, power;
        reg sign;
        reg [7:0] exp_raw;
        reg [22:0] mantissa;
        integer unbiasedExp;
        integer i;
        begin
            // Extract components
            sign     = float_num[31];
            exp_raw  = float_num[30:23];
            mantissa = float_num[22:0];
  
            // Check special cases:
            if(exp_raw == 8'b0) begin
                // Zero or Denormalized number.
                if(mantissa == 23'b0) begin
                    $display("Special Case: %sZero", (sign ? "-" : "+"));
                end else begin
                    // Denormalized number
                    unbiasedExp = -126;
                    fraction_part = 0.0;
                    power = 0.5; // weight for bit 22
                    for(i = 22; i >= 0; i = i - 1) begin
                        if(mantissa[i])
                            fraction_part = fraction_part + power;
                        power = power / 2.0;
                    end
                    result = (sign ? -1.0 : 1.0) * fraction_part * (2.0 ** unbiasedExp);
                    $display("Denormalized Number: %.20f", result);
                end
            end
            else if(exp_raw == 8'hFF) begin
                // Infinity or NaN.
                if(mantissa == 23'b0) begin
                    $display("Special Case: %sInfinity", (sign ? "-" : "+"));
                end else begin
                    $display("Special Case: NaN");
                end
            end
            else begin
                // Normalized number.
                unbiasedExp = exp_raw - 127;
                fraction_part = 1.0;  // Implicit leading 1
                power = 0.5;          // Start with weight for bit 22
                for(i = 22; i >= 0; i = i - 1) begin
                    if(mantissa[i])
                        fraction_part = fraction_part + power;
                    power = power / 2.0;
                end
                result = (sign ? -1.0 : 1.0) * fraction_part * (2.0 ** unbiasedExp);
                $display("%.100f", result);
            end
        end
  endtask
  
endmodule



