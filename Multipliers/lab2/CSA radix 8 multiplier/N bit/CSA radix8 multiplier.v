module CSA_radix8_mul #(parameter integer N = 32)(
  input clk, rst,                             // Clock and reset
  input wire signed [N-1:0] a, x,               // N-bit signed operands
  output wire signed [2*N-1:0] p                // 2*N-bit signed product
);

  // Compute number of iterations required (ceiling of (N+1)/3)
  localparam ITER = (N+3)/3;
  
  // Counter for iteration steps (width determined by ITER)
  reg [$clog2(ITER+1)-1:0] counter;
  
  // CSA outputs:
  // First two CSAs produce vectors of width (N+2) bits and the third one (N+3) bits.
  wire [N+1:0] s1, c1;    // CSA1 outputs (N+2 bits)
  wire [N+1:0] s2, c2;    // CSA2 outputs (N+2 bits)
  wire [N+2:0] s3, c3;    // CSA3 outputs (N+3 bits)
  
  // Large-bit adder output (N+1 bits) and a fixed 3-bit small sum.
  wire [N:0] bigS;
  wire [2:0] smallS;
  wire smallC;
  
  // Registers for the partial product and intermediate results.
  reg signed [2*N-1:0] p_reg;  // Partial product register (2*N bits)
  reg [N-1:0] sum_reg;         // Sum register (N bits)
  reg [N:0] carry_reg;         // Carry register (N+1 bits)
  reg ff;                      // Flip-flop for the small-bit carry
  
  // Multiplexers for partial products based on Booth encoding.
  // These expressions sign-extend 'a' to (N+2) bits.
  wire [N+1:0] a_x0_mux = (p_reg[0] ? {{2{a[N-1]}}, a} : {N+2{1'b0}});
  wire [N+1:0] a_x1_mux = (p_reg[1] ?((counter == ITER-1) ? -({a[N-1], a, 1'b0}):{a[N-1], a, 1'b0}):{N+2{1'b0}});
  wire [N+1:0] a_x2_mux = (p_reg[2] ? {a, 2'b0} : {N+2{1'b0}});
  
  // 3-bit small adder instance (assumed parameterized)
  adder #(3) add1 (
    .a(s3[2:0]),
    .b({c3[1:0], ff}),
    .cin(1'b0),
    .s(smallS),
    .cout(smallC)
  );
  
  // (N+1)-bit large adder instance.
  // The adder adds {sum_reg[N-1], sum_reg} (N+1 bits) to carry_reg.
  adder #(N+1) add2 (
    .a({sum_reg[N-1], sum_reg}),
    .b(carry_reg),
    .cin(ff),
    .s(bigS),
    .cout()
  );
  
  // Carry-Save Adder (CSA) instances.
  CSA #(N+2) csa1 (
    .x(a_x0_mux),
    .y(a_x1_mux),
    .z(a_x2_mux),
    .s(s1),
    .c(c1)
  );
  
  CSA #(N+2) csa2 (
    .x(s1),
    .y({carry_reg[N], carry_reg}),              // Sign extension of carry_reg to (N+2) bits
    .z({{2{sum_reg[N-1]}}, sum_reg}),             // Sign extension of sum_reg to (N+2) bits
    .s(s2),
    .c(c2)
  );
  
  CSA #(N+3) csa3 (
    .x({s2[N+1], s2}),                           // Extend s2 to (N+3) bits
    .y({c2, 1'b0}),
    .z({c1, 1'b0}),
    .s(s3),
    .c(c3)
  );
  
  // Register update for the final product.
  // On reset, initialize with x in the lower half and zeros in the upper half.
  // In each iteration, shift p_reg by 3 bits and insert the new 3-bit sum.
  // On the final iteration (counter == ITER), combine the large sum result.
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      p_reg <= { {N{1'b0}}, x }; // Upper N bits zero, lower N bits x.
    end else begin
      if (counter == ITER) begin
        // Combine the (N+1)-bit large sum (dropping the MSB to get N-1 bits)
        // with the lower (N+1) bits of p_reg.
        p_reg <= {bigS[N-2:0], p_reg[N:0]};
      end else begin
        // Shift right by 3 bits and insert the 3-bit small sum.
        // p_reg[2*N-1 : N+1] is the upper (N-1) bits,
        // p_reg[N:3] is the lower (N+1-3 = N-2) bits.
        p_reg <= {p_reg[2*N-1 : N+1], smallS, p_reg[N:3]};
      end
    end
  end
  
  // Counter update for iterations.
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 0;
    end else if (counter < ITER) begin
      counter <= counter + 1;
    end else begin
      counter <= 0;
    end
  end
  
  // Update registers for the intermediate CSA results.
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      sum_reg <= 0;
      carry_reg <= 0;
    end else begin
      // Extract N bits for sum and N+1 bits for carry.
      sum_reg   <= s3[N+2:3];
      carry_reg <= c3[N+2:2];
    end
  end
  
  // Update the flip-flop for the small-bit adder's carry.
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ff <= 0;
    end else begin
      ff <= smallC;
    end
  end
  
  // Assign the final product output.
  assign p = p_reg;
  
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



