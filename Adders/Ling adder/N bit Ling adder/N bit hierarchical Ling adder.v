module N_bit_hierarchical_Ling_CLA #(parameter N = 64 )
  (
  input wire [N-1:0] a,b,  // 64-bit input operands a and b
  input wire cin,         // Carry-in input (initial carry value)
  output wire [N-1:0] s,   // 64-bit sum output
  output wire cout        // Carry-out output (final carry value)
  );

  wire [N-1:0] p,g;        // Intermediate propagate and generate signals
  wire [N:1] h;            // Intermediate carry signals (64 bits, with c[64] being the final carry-out)

  // Instantiate the GPgeneration module to calculate propagate and generate signals
  N_bit_GPgeneration gpg (a,b,p,g);

  // Instantiate the 64-bit carry look-ahead adder (CLA) to compute carry signals
  N_bit_Ling_CLA cla (cin,p,g,h);

  // Instantiate the SUMgenerator to compute the sum (s) based on propagate signals and carry signals
  N_bit_SUMgenerator sg ({h[N-1:1],cin},p,g,s);

  // Assign the final carry-out to the output cout
  assign cout = h[N]&(p[N-1]|g[N-1]);

endmodule


`timescale 1ns / 1ps
module N_bit_hierarchical_Ling_CLA_tb;
// Parameters
parameter N = 64;
// Inputs
reg [N-1:0] a;           // 64-bit input operand a
reg [N-1:0] b;           // 64-bit input operand b
reg cin;                 // Carry-in input

// Outputs
wire [N-1:0] sum;       // 64-bit sum output
wire cout;              // Carry-out output

// Instantiate the Unit Under Test (UUT)
N_bit_hierarchical_Ling_CLA #(N) uut (
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
  #10 a = 64'd15; b = 64'd10; cin = 0; // Test case 1: 15 + 10 = 25
  #10 a = 64'd15; b = 64'd10; cin = 1; // Test case 2: 15 + 10 + 1 = 26
  #10 a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001; cin = 0; // Test case 3: Max value + 1 = 18446744073709551616
  #10 a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001; cin = 1; // Test case 4: Max value + 1 + 1 = 18446744073709551617
  #10 a = 64'h123456789ABCDEF0; b = 64'hFEDCBA9876543210; cin = 0; // Test case 5: 1311768467463790320 + 18364758544493064720 = 19676527011956855040
  #10 a = 64'h123456789ABCDEF0; b = 64'hFEDCBA9876543210; cin = 1; // Test case 6: 1311768467463790320 + 18364758544493064720 + 1 = 19676527011956855041

  // Add more test cases as needed
  #10 $stop; // Stop the simulation
end

// Monitor the signals during simulation
initial begin
  $monitor("At time %t, a = %d, b = %d, cin = %b, sum = %d, cout = %b, {cout,sum} = %d",
  $time, a, b, cin, sum, cout, {cout,sum});
end
endmodule
