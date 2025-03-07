module adder #(parameter N) 
(
  input signed [N-1:0] a,b,  // 32-bit signed inputs
  input cin,                // Carry-in bit
  output signed [N-1:0] s,   // 32-bit signed sum output
  output cout               // Carry-out bit
  );
  
  // Perform addition including carry-in
  assign {cout, s} = a + b + cin;
endmodule


module right_shift_mul_N_bit #(parameter N=32) 
(
  input clk, rst,                // Clock and Reset signals
  input signed [N-1:0] a, x,       // 32-bit signed multiplicand and multiplier
  output signed [2*N-1:0] p      // 64-bit signed product output
  );
  
  reg signed [2*N-1:0] p_reg;
  reg [$clog2(N):0] counter;              // Counter to track iterations
  wire signed [N-1:0] sum;         // Stores partial sum
  wire cout;
  
  // Multiplexer to determine if we should add a, subtract a, or add 0
  wire signed [N-1:0] a_mux = p_reg[0] ? (counter[$clog2(N)] ? (~a) : a) : 0;
  wire MSB_mux = counter[$clog2(N)] ? (~a[N-1]) : a[N-1];
  
  // Instantiate the adder module to handle signed addition with carry
  adder #(N) add1 (p_reg[2*N-1:N], a_mux, counter[$clog2(N)], sum,cout);
  
  // Product register update logic
  /*product_reg*/always @(posedge clk or posedge rst) begin
    if (rst) begin
      // On reset, initialize the product register with the multiplier
      p_reg <= {{N{1'b0}}, x};
    end else begin
      if (p[0]) begin
        // If LSB of product is 1, perform addition/subtraction and shift
        p_reg <= {a?MSB_mux:0, sum, p_reg[N-1:1]};
      end else begin
        // If LSB is 0, simply shift right with sign extension
        p_reg <= {p_reg[2*N-1], p_reg[2*N-1:1]};
      end
    end
  end
  
  // Counter register to keep track of iterations
  /*counter_reg*/always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 6'd1; // Start counter from 1
    end else begin
      counter <= counter + 1; // Increment counter at each clock cycle
    end
  end
  
  assign p=p_reg;
  
endmodule


`timescale 1ns/1ps

module tb_right_shift_mul_N_bit();
  reg clk, rst;
  reg signed [31:0] a, x;
  wire signed [63:0] p;
  
  reg signed [63:0] expected;

  right_shift_mul_N_bit uut (
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


