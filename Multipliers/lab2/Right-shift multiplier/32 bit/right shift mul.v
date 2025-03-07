// 32-bit signed adder module
module adder (
  input signed [31:0] a, b,  // 32-bit signed inputs
  input cin,                // Carry-in bit
  output signed [31:0] s,   // 32-bit signed sum output
  output cout               // Carry-out bit
  );
  
  // Perform addition including carry-in
  assign {cout, s} = a + b + cin;
endmodule

// 32-bit signed multiplication using right shift algorithm
module right_shift_mul_32bit (
  input clk, rst,                // Clock and Reset signals
  input signed [31:0] a, x,       // 32-bit signed multiplicand and multiplier
  output signed [63:0] p          // 64-bit signed product output
  );
  
  reg signed [63:0] p_reg;        // Register to store the product
  reg [5:0] counter;              // Counter to track iterations (max 32)
  wire signed [31:0] sum;         // Stores partial sum from adder
  wire cout;                      // Carry-out bit (not used in this case)
  
  // Multiplexer logic to decide if we should add, subtract, or add 0
  wire signed [31:0] a_mux = p_reg[0] ? (counter[5] ? (~a) : a) : 0;
  wire MSB_mux = counter[5] ? (~a[31]) : a[31];
  
  // Instantiate the adder module to handle signed addition with carry
  adder add1 (p_reg[63:32], a_mux, counter[5], sum, cout);
  
  // Product register update logic (Booth's algorithm variation)
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // On reset, initialize the product register with the multiplier
      p_reg <= {32'b0, x};
    end else begin
      if (p[0]) begin
        // If LSB of product is 1, perform addition/subtraction and shift
        p_reg <= {a ? MSB_mux : 0, sum, p_reg[31:1]};
      end else begin
        // If LSB is 0, simply shift right with sign extension
        p_reg <= {p_reg[63], p_reg[63:1]};
      end
    end
  end
  
  // Counter register to track multiplication steps
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 6'd1; // Start counter from 1
    end else begin
      counter <= counter + 1; // Increment counter at each clock cycle
    end
  end
  
  // Assign product output
  assign p = p_reg;
  
endmodule

// Testbench for right_shift_mul_32bit module
`timescale 1ns/1ps
module tb_right_shift_mul_32bit();
  reg clk, rst;
  reg signed [31:0] a, x;
  wire signed [63:0] p;
  reg signed [63:0] expected;

  // Instantiate the multiplication module
  right_shift_mul_32bit uut (
    .clk(clk),
    .rst(rst),
    .a(a),
    .x(x),
    .p(p)
  );

  // Clock generation (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
 
  // Main test sequence
  initial begin
    
    // Test various cases with signed numbers
    
    // Test Case 1: Positive * Negative
    rst = 1;
    a = 32'h12345678;
    x = -32'h12345678;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 2: Negative * Positive
    rst = 1;
    a = -32'h1A2B3C4D;
    x = 32'h11223344;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 3: Positive * Positive
    rst = 1;
    a = 32'h7FFFFFFF;
    x = 32'h00000002;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 4: Negative * Negative
    rst = 1;
    a = -32'h40000000;
    x = -32'h00000002;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 5: Zero * Any number
    rst = 1;
    a = 32'h00000000;
    x = 32'hABCDEF12;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 6: Maximum Negative * -1 (Check overflow behavior)
    rst = 1;
    a = -32'h80000000;
    x = -32'h00000001;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 7: Large numbers multiplication
    rst = 1;
    a = 32'h76543210;
    x = 32'h12345678;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 8: Small numbers multiplication
    rst = 1;
    a = 32'h00000002;
    x = 32'h00000003;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 9: Negative small numbers multiplication
    rst = 1;
    a = -32'h00000002;
    x = -32'h00000003;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 10: One operand as one
    rst = 1;
    a = 32'h00000001;
    x = 32'h76543210;
    expected = a * x;
    #5;
    rst = 0;
    #320;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    $stop;
  end
endmodule
