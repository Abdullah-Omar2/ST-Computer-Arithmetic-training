module Divider #(parameter N = 24)
(
    input                  clk,       // Clock signal
    input                  rst,       // Synchronous reset (active high)
    input  [N-1:0]         dividend,  // Dividend input
    input  [N-1:0]         divisor,   // Divisor input (assume nonzero)
    output reg [N-1:0]     quotient,  // Quotient output
    output reg [N-1:0]     remainder, // Remainder output
    output reg             done       // Asserted for one clock cycle when division is complete
);

    // Register to hold both remainder (upper half) and dividend (lower half)
    reg [2*N-1:0] reg_div;
    // Counter to track iterations (needs to count up to N for N-bit division)
    reg [$clog2(N+1)-1:0] count;

    // Shifted register for the division algorithm
    wire [2*N-1:0] shifted;
    assign shifted = reg_div << 1; // Shift left to bring in the next bit

    // Compute next value of reg_div based on comparison with divisor
    wire [2*N-1:0] calc_reg_div;
    assign calc_reg_div = (shifted[2*N-1:N] >= divisor) ?
                          { shifted[2*N-1:N] - divisor, shifted[N-1:1], 1'b1 } : // Subtract divisor and set LSB to 1
                          shifted; // Otherwise, just shift

    always @(posedge clk) begin
        if (rst) begin
            // Reset state: Load dividend into lower half; upper half is zero.
            reg_div   <= { {N{1'b0}}, dividend };
            count     <= N; // Initialize counter to N
            done      <= 1'b0;
            quotient  <= {N{1'b0}};
            remainder <= {N{1'b0}};
        end else if (count != 0) begin
            // Perform one iteration of division per clock cycle
            reg_div   <= calc_reg_div;
            count     <= count - 1;
            if (count == 1) begin
                // On final iteration, latch results
                quotient  <= calc_reg_div[N-1:0];
                remainder <= calc_reg_div[2*N-1:N];
                done      <= 1'b1; // Indicate completion
            end else begin
                done      <= 1'b0; // Keep done low otherwise
            end
        end
    end
endmodule


`timescale 1ns/1ps
module Divider_tb;
    parameter N = 24;

    // Testbench signals
    reg               clk;
    reg               rst;
    reg  [N-1:0]      dividend;
    reg  [N-1:0]      divisor;
    wire [N-1:0]      quotient;
    wire [N-1:0]      remainder;
    wire              done;

    // Instantiate the Divider module (Device Under Test)
    Divider #(.N(N)) uut (
        .clk(clk),
        .rst(rst),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .done(done)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 ns
    end

    // Test cases
    initial begin
        // Test case 1: Divide 100 by 3
        dividend = 24'b101110000000000000000000;
        divisor  = 24'b101000000000000000000000;
        rst = 1; // Assert reset to load new inputs
        #10;
        rst = 0; // Release reset
        wait(done); // Wait for division to complete
        $display("Time: %0t | Test 1: Dividend = %d, Divisor = %d, Quotient = %d, Remainder = %d", 
                 $time, dividend, divisor, quotient, remainder);
        #20;

        // Test case 2: Divide 1000 by 10
        dividend = 24'd1000;
        divisor  = 24'd10;
        rst = 1; 
        #10;
        rst = 0;
        wait(done);
        $display("Time: %0t | Test 2: Dividend = %d, Divisor = %d, Quotient = %d, Remainder = %d", 
                 $time, dividend, divisor, quotient, remainder);
        #20;

        // Test case 3: Divide 5000000 by 123
        dividend = 24'd5000000;
        divisor  = 24'd123;
        rst = 1;
        #10;
        rst = 0;
        wait(done);
        $display("Time: %0t | Test 3: Dividend = %d, Divisor = %d, Quotient = %d, Remainder = %d", 
                 $time, dividend, divisor, quotient, remainder);
        #20;

        // Test case 4: Dividend smaller than divisor: 50 / 7
        dividend = 24'd50;
        divisor  = 24'd7;
        rst = 1;
        #10;
        rst = 0;
        wait(done);
        $display("Time: %0t | Test 4: Dividend = %d, Divisor = %d, Quotient = %d, Remainder = %d", 
                 $time, dividend, divisor, quotient, remainder);
        #20;

        // Test case 5: Zero dividend: 0 / 5
        dividend = 24'd0;
        divisor  = 24'd5;
        rst = 1;
        #10;
        rst = 0;
        wait(done);
        $display("Time: %0t | Test 5: Dividend = %d, Divisor = %d, Quotient = %d, Remainder = %d", 
                 $time, dividend, divisor, quotient, remainder);
        #20;

        // Test case 6: Maximum dividend: (2^24 - 1) / 255
        dividend = 24'd16777215;
        divisor  = 24'd255;
        rst = 1;
        #10;
        rst = 0;
        wait(done);
        $display("Time: %0t | Test 6: Dividend = %d, Divisor = %d, Quotient = %d, Remainder = %d", 
                 $time, dividend, divisor, quotient, remainder);
        #20;

        // Test case 7: Equal dividend and divisor: 500 / 500
        dividend = 24'd500;
        divisor  = 24'd500;
        rst = 1;
        #10;
        rst = 0;
        wait(done);
        $display("Time: %0t | Test 7: Dividend = %d, Divisor = %d, Quotient = %d, Remainder = %d", 
                 $time, dividend, divisor, quotient, remainder);
        #20;

        $stop; // End simulation
    end
endmodule
