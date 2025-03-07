module CSA_radix8_mul (
  input clk, rst,                     // Clock and reset signals
  input wire signed [31:0] a, x,       // 32-bit signed input operands
  output wire signed [63:0] p         // 64-bit signed product output
  );
  
  reg [4:0] counter;                   // Counter to track iteration steps
  
  wire [33:0] s1, c1;                   // Sum and carry outputs from first CSA
  wire [33:0] s2, c2;                   // Sum and carry outputs from second CSA
  wire [34:0] s3, c3;                   // Sum and carry outputs from third CSA
  
  wire [32:0] bigS;                      // Large sum from final adder
  wire [2:0] smallS;                     // Small sum from the small-bit adder
  wire smallC;                           // Carry bit from the small-bit adder
  
  reg signed [63:0] p_reg;               // Register to hold the partial product
  reg [31:0] sum_reg;                    // Sum register for intermediate results
  reg [32:0] carry_reg;                  // Carry register for intermediate results
  reg ff;                                // Flip-flop to store carry bit
  
  // Multiplexer for partial products based on Booth encoding
  wire [33:0] a_x0_mux = (p_reg[0] ? {{2{a[31]}}, a} : 34'b0); // Booth encoding for 0x multiplier
  wire [33:0] a_x1_mux = (p_reg[1] ? ((counter == 10) ? -({a[31], a, 1'b0}) : {a[31], a, 1'b0}) : 34'b0); // Booth encoding for 1x multiplier
  wire [33:0] a_x2_mux = (p_reg[2] ? {a, 2'b0} : 34'b0); // Booth encoding for 2x multiplier
  
  // Small-bit adder (3-bit addition)
  adder #(3) add1 (
    .a(s3[2:0]),
    .b({c3[1:0], ff}),
    .cin(1'b0),
    .s(smallS),
    .cout(smallC)
  );
  
  // Large-bit adder (33-bit addition)
  adder #(33) add2 (
    .a({sum_reg[31], sum_reg}),
    .b(carry_reg),
    .cin(ff),
    .s(bigS),
    .cout()
  );
  
  // Carry-Save Adders (CSA) for partial product accumulation
  CSA #(34) csa1 (
    .x(a_x0_mux),
    .y(a_x1_mux),
    .z(a_x2_mux),
    .s(s1),
    .c(c1)
  );
  
  CSA #(34) csa2 (
    .x(s1),
    .y({carry_reg[32], carry_reg}),
    .z({{2{sum_reg[31]}}, sum_reg}),
    .s(s2),
    .c(c2)
  );
  
  CSA #(35) csa3 (
    .x({s2[33], s2}),
    .y({c2, 1'b0}),
    .z({c1, 1'b0}),
    .s(s3),
    .c(c3)
  );
  
  // Register to hold the final product
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      p_reg <= {32'b0, x}; // Initialize with input multiplicand
    end else begin
      if (counter == 11) begin
        p_reg <= {bigS[30:0], p_reg[32:0]}; // Update with large sum result
      end else begin
        p_reg <= {p_reg[63:33], smallS, p_reg[32:3]}; // Shift the register with small sum
      end
    end
  end
  
  // Counter to track iterations (controls Booth multiplication steps)
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 5'd0;
    end else if (counter < 11) begin
      counter <= counter + 1;
    end else begin
      counter <= 5'd0;
    end
  end
    
  // Registers to hold partial product sum and carry
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      sum_reg <= 0;
      carry_reg <= 0;
    end else begin
      sum_reg <= s3[34:3]; // Store sum output
      carry_reg <= c3[34:2]; // Store carry output
    end
  end
  
  // Flip-flop to store small carry bit
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ff <= 0;
    end else begin
      ff <= smallC;
    end
  end
  
  assign p = p_reg; // Assign the final product output
  
endmodule


`timescale 1ns/1ps

module tb_CSA_radix8_mul();
  // Clock and reset signals
  reg clk, rst;
  // Input operands (signed 32-bit)
  reg signed [31:0] a, x;
  // Expected result (signed 64-bit)
  reg signed [63:0] expected;
  // Output product from the multiplier module
  wire signed [63:0] p;
  
  // Instantiate the CSA radix-8 multiplier module
  CSA_radix8_mul uut (
    .clk(clk),
    .rst(rst),
    .a(a),
    .x(x),
    .p(p)
  );

  // Clock generation (100 MHz -> 10ns period -> 5ns half-period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Toggle clock every 5ns
  end

  // Main test sequence
  initial begin
    // Apply reset
    rst = 1;
    a = 32'hFFFFFFFF; // -1 in signed 32-bit
    x = 32'hFFFFFFFF; // -1 in signed 32-bit
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 2: Maximum positive numbers
    rst = 1;
    a = 32'h7FFFFFFF; // 2147483647 in signed 32-bit
    x = 32'h7FFFFFFF; // 2147483647 in signed 32-bit
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 3: Mixed sign multiplication
    rst = 1;
    a = -12345678;
    x = 98765432;
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 4: Zero multiplication
    rst = 1;
    a = 0;
    x = 123456;
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 5: One operand as one
    rst = 1;
    a = 1;
    x = -98765;
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Additional Test Cases
    // Test Case 6: Small positive numbers
    rst = 1;
    a = 12;
    x = 34;
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 7: Large negative and positive number
    rst = 1;
    a = -2147483647;
    x = 2;
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 8: Power of two multiplication
    rst = 1;
    a = 1024;
    x = 2048;
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 9: Small negative numbers
    rst = 1;
    a = -3;
    x = -7;
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Test Case 10: Random large values
    rst = 1;
    a = 987654;
    x = 123456;
    expected = a * x;
    #5;
    rst = 0;
    #120;
    $display("%d * %d = %d (expected %d)", a, x, p, expected);
    
    // Stop simulation
    $stop;
  end

endmodule



