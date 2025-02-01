module _64_bit_hierarchical_Ling_adder
  (
  input wire [63:0] a, b,  // 64-bit input operands
  input wire cin,          // Carry-in input (initial carry value)
  output wire [63:0] s,    // 64-bit sum output
  output wire cout         // Carry-out output (final carry value)
  );

  wire [63:0] p, g;        // Intermediate propagate and generate signals
  wire [64:1] h;           // Carry signals (64 bits, with h[64] as final carry-out)

  // Generate propagate (p) and generate (g) signals for each bit
  GPgeneration gpg (a, b, g, p);

  // Compute the carry signals using the 64-bit Ling CLA
  _64_bit_Ling_CLA lcla (cin, p, g, h);

  // Compute the sum bits using propagate and carry signals
  SUMgenerator sg ({h[63:1], cin}, p, g, s);

  // Assign the final carry-out signal
  assign cout = (h[64] & (p[63] | g[63]));

endmodule




`timescale 1ns / 1ps
module _64_bit_hierarchical_Ling_adder_tb;

// Parameters
parameter N = 64;

// Inputs
reg [N-1:0] a;
reg [N-1:0] b;
reg cin;

// Outputs
wire [N-1:0] sum;
wire cout;

// Instantiate the Unit Under Test (UUT)
_64_bit_hierarchical_Ling_adder uut (
  .a(a),
  .b(b),
  .cin(cin),
  .s(sum),
  .cout(cout)
);

initial begin
  // Initialize Inputs
  a = 0;
  b = 0;
  cin = 0;

  // Apply test vectors
  #10 a = 64'd15; b = 64'd10; cin = 0;  // 15 + 10 = 25
  #10 a = 64'd15; b = 64'd10; cin = 1;  // 15 + 10 + 1 = 26
  #10 a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001; cin = 0; // 18446744073709551615 + 1 = 18446744073709551616
  #10 a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001; cin = 1; // 18446744073709551615 + 1 + 1 = 18446744073709551617
  #10 a = 64'h123456789ABCDEF0; b = 64'hFEDCBA9876543210; cin = 0; // Large number addition
  #10 a = 64'h123456789ABCDEF0; b = 64'hFEDCBA9876543210; cin = 1; // Large number addition with carry

  // Add more test cases if needed
  #10 $stop; // Stop the simulation
end

// Monitor signals and print results
initial begin
  $monitor("At time %t, a = %d, b = %d, cin = %b, sum = %d, cout = %b, {cout, sum} = %d",
  $time, a, b, cin, sum, cout, {cout, sum});
end

endmodule
