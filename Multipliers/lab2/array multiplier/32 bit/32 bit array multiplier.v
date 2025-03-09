`timescale 1ns/1ps

// Full Adder Module
module full_adder (
  input a, b, cin,
  output s, cout
);
  assign s = a ^ b ^ cin;               // Sum calculation
  assign cout = (a & b) | (cin & (a ^ b)); // Carry calculation
endmodule

// Array Multiplier Module (32-bit signed multiplication)
module array_multiplier (
  input signed [31:0] a, x,
  output signed [63:0] p
);
  
  wire [31:0] sum [31:0];    // Partial sum matrix
  wire [30:0] carry [31:0];  // Carry matrix
  
  // Generate first row of partial products
  assign sum[0] = {(~x[0] & a[31]), {31{x[0]}} & a[30:0]};
  assign carry[0] = 31'b0; // Initialize carry
  
  genvar i, j;
  
  // Set the sign extension for partial products
  generate
    for (i = 1; i < 31; i = i + 1) begin
      assign sum[i][31] = (a[31] & ~x[i]);
    end
  endgenerate

  // Perform addition using full adders
  generate
    for (i = 0; i < 31; i = i + 1) begin
      for (j = 0; j < 31; j = j + 1) begin
        if (i != 30) begin
          full_adder fa (
            .a(carry[i][j]),
            .b(sum[i][j+1]),
            .cin(x[i+1] & a[j]),
            .s(sum[i+1][j]),
            .cout(carry[i+1][j])
          );
        end else begin
          full_adder fa (
            .a(carry[i][j]),
            .b(sum[i][j+1]),
            .cin(x[i+1] & ~a[j]),
            .s(sum[i+1][j]),
            .cout(carry[i+1][j])
          );
        end
      end
    end
  endgenerate
  
  wire [31:0] final_level_carry;
  wire [30:0] final_level_sum;

  // Final level addition
  full_adder final_fa (
    .a(sum[31][0]),
    .b(a[31]),
    .cin(x[31]),
    .s(p[31]),
    .cout(final_level_carry[0])
  );

  wire c_for_sign;
  full_adder fa1 (
    .a(a[31] & x[31]),
    .b(~a[31]),
    .cin(~x[31]),
    .s(sum[31][31]),
    .cout(c_for_sign)
  );
  
  generate
    for (i = 0; i < 31; i = i + 1) begin
      full_adder fa2 (
        .a(carry[31][i]),
        .b(sum[31][i+1]),
        .cin(final_level_carry[i]),
        .s(final_level_sum[i]),
        .cout(final_level_carry[i+1])
      );
    end
  endgenerate

  full_adder fa3 (
    .a(1'b1),
    .b(c_for_sign),
    .cin(final_level_carry[31]),
    .s(p[63]),
    .cout()
  );

  assign p[62:32] = final_level_sum;
  
  generate
    for (i = 0; i < 31; i = i + 1) begin
      assign p[i] = sum[i][0];
    end
  endgenerate

endmodule

// Testbench for Array Multiplier
module array_multiplier_tb;
  reg signed [31:0] a, x;
  wire signed [63:0] p;
  reg signed [63:0] expected;
  
  // Instantiate the module under test
  array_multiplier uut (
    .a(a),
    .x(x),
    .p(p)
  );
  
  initial begin
    $monitor("Time = %0t | a = %d | x = %d | p = %d | Expected = %d", $time, a, x, p, expected);
    
    // Apply test cases
    a = 32'd10; x = 32'd5; expected = a * x; #10;
    a = -32'd10; x = 32'd5; expected = a * x; #10;
    a = 32'd10; x = -32'd5; expected = a * x; #10;
    a = -32'd10; x = -32'd5; expected = a * x; #10;
    a = 32'd12345; x = 32'd6789; expected = a * x; #10;
    a = -32'd12345; x = 32'd6789; expected = a * x; #10;
    a = 32'd0; x = 32'd1234; expected = a * x; #10;
    a = 32'd5678; x = 32'd0; expected = a * x; #10;
    a = 32'd2147483647; x = 32'd2; expected = a * x; #10;
    a = -32'd2147483648; x = -32'd1; expected = a * x; #10;
    
    // End simulation
    $stop;
  end
endmodule
