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

    // reg_div holds both the remainder (upper half) and dividend (lower half)
    reg [2*N-1:0] reg_div;
    // Counter to track iterations (needs to count up to N)
    reg [$clog2(N+1)-1:0] count;

    // Intermediate combinational signals
    wire [2*N-1:0] shifted;
    assign shifted = reg_div << 1;

    wire [2*N-1:0] calc_reg_div;
    assign calc_reg_div = (shifted[2*N-1:N] >= divisor) ?
                          { shifted[2*N-1:N] - divisor, shifted[N-1:1], 1'b1 }:
                          shifted;

    always @(posedge clk) begin
        if (rst) begin
            // Load new dividend into lower half; upper half is zero.
            reg_div   <= { {N{1'b0}}, dividend };
            count     <= N;
            done      <= 1'b0;
            quotient  <= {N{1'b0}};
            remainder <= {N{1'b0}};
        end else if (count != 0) begin
            // Update state registers with nonblocking assignments.
            reg_div   <= calc_reg_div;
            count     <= count - 1;
            if (count == 1) begin
                quotient  <= calc_reg_div[N-1:0];
                remainder <= calc_reg_div[2*N-1:N];
                done      <= 1'b1;  // Assert done for one clock cycle.
            end else begin
                done      <= 1'b0;
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
        forever #5 clk = ~clk;
    end

    // Test stimulus with multiple cases
    initial begin
        // Test case 1: Divide 100 by 3
        dividend = 24'd100;
        divisor  = 24'd3;
        rst = 1; // assert reset to load new inputs
        #10;
        rst = 0; // release reset
        wait(done);
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

        $stop;
    end

endmodule

