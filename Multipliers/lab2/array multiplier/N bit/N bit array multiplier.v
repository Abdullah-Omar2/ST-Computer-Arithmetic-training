`timescale 1ns/1ps

// Full Adder Module
module full_adder (
  input a, b, cin,       // Inputs: two bits to add and a carry-in
  output s, cout         // Outputs: sum and carry-out
);
  assign s = a ^ b ^ cin;               // Sum calculation using XOR
  assign cout = (a & b) | (cin & (a ^ b)); // Carry calculation using AND and OR
endmodule

// Array Multiplier Module (32-bit signed multiplication)
module array_multiplier #(parameter N=32) (
  input signed [N-1:0] a, x,       // 32-bit signed multiplicands
  output signed [2*N-1:0] p        // 64-bit signed product
);
  
  wire [N-1:0] sum [N-1:0];    // Partial sum matrix
  wire [N-2:0] carry [N-1:0];  // Carry matrix
  
  // Generate first row of partial products
  assign sum[0] = {(~x[0] & a[N-1]), {(N-1){x[0]}} & a[N-2:0]};
  assign carry[0] = {(N-1){1'b0}}; // Initialize carry to zero
  
  genvar i, j;
  
  // Set the sign extension for partial products
  generate
    for (i = 1; i < N-1; i = i + 1) begin
      assign sum[i][N-1] = (a[N-1] & ~x[i]); // Sign bit extension logic
    end
  endgenerate

  // Perform addition using full adders for each bit position
  generate
    for (i = 0; i < N-1; i = i + 1) begin
      for (j = 0; j < N-1; j = j + 1) begin
        if (i != N-2) begin
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
  
  wire [N-1:0] final_level_carry;
  wire [N-2:0] final_level_sum;

  // Final level addition to handle last row of multiplication
  full_adder final_fa (
    .a(sum[N-1][0]),
    .b(a[N-1]),
    .cin(x[N-1]),
    .s(p[N-1]),
    .cout(final_level_carry[0])
  );

  wire c_for_sign;
  full_adder fa1 (
    .a(a[N-1] & x[N-1]),
    .b(~a[N-1]),
    .cin(~x[N-1]),
    .s(sum[N-1][N-1]),
    .cout(c_for_sign)
  );
  
  // Final carry propagation through full adders
  generate
    for (i = 0; i < N-1; i = i + 1) begin
      full_adder fa2 (
        .a(carry[N-1][i]),
        .b(sum[N-1][i+1]),
        .cin(final_level_carry[i]),
        .s(final_level_sum[i]),
        .cout(final_level_carry[i+1])
      );
    end
  endgenerate

  // Handle sign extension
  full_adder fa3 (
    .a(1'b1),
    .b(c_for_sign),
    .cin(final_level_carry[31]),
    .s(p[2*N-1]),
    .cout()
  );

  assign p[2*N-2:N] = final_level_sum; // Assign final sum to product output
  
  // Assign least significant bits of product
  generate
    for (i = 0; i < N-1; i = i + 1) begin
      assign p[i] = sum[i][0];
    end
  endgenerate

endmodule

// Testbench for Array Multiplier
module array_multiplier_tb;
  reg signed [31:0] a, x;  // Input test values
  wire signed [63:0] p;    // Output product
  reg signed [63:0] expected;  // Expected multiplication result
  
  // Instantiate the module under test
  array_multiplier uut (
    .a(a),
    .x(x),
    .p(p)
  );
  
  initial begin
    // Monitor values for debugging
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
