module _64bit_Ladner_fischer_adder (
  input wire [63:0] a,b,  // 64-bit input operands
  input wire cin,         // Carry-in bit
  output wire [63:0] s,   // 64-bit sum output
  output wire cout        // Carry-out bit
  );
  wire [63:0] g,p,G,P,c;  // Intermediate signals for carry generation
  
  // Generate propagate and generate signals
  GPgeneration gpg (a,b,p,g);
  
  // Compute the group generate and propagate signals using the Ladner-Fischer network
  _64bit_Lander_fischer_network lfn (g,p,G,P);
  
  // Compute the carry signals
  assign c[63:0]=G[63:0]|(cin&P[63:0]);
  
  // Generate the final sum output
  SUMgenerator sg ({c[62:0],cin},p,s);
  
  // Assign the final carry-out
  assign cout = c[63];
  
endmodule


`timescale 1ns / 1ps
module _64bit_Ladner_fischer_adder_tb;
// Parameters
parameter N = 64;
// Inputs
reg [N-1:0] a; // First operand
reg [N-1:0] b; // Second operand
reg cin; // Carry-in bit
// Outputs
wire [N-1:0] sum; // Sum output
wire cout; // Carry-out bit
// Instantiate the Unit Under Test (UUT)
_64bit_Ladner_fischer_adder uut (
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
#10 a = 64'd15; b = 64'd10; cin = 0; // 15 + 10 = 25
#10 a = 64'd15; b = 64'd10; cin = 1; // 15 + 10 + 1 = 26
#10 a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001; cin = 0; // Maximum unsigned value + 1 = Overflow
#10 a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000001; cin = 1; // Overflow with carry-in
#10 a = 64'h123456789ABCDEF0; b = 64'hFEDCBA9876543210; cin = 0; // Test with large numbers
#10 a = 64'h123456789ABCDEF0; b = 64'hFEDCBA9876543210; cin = 1; // Large numbers with carry-in
// Add more test cases as needed
#10 $stop; // Stop the simulation
end
initial begin
// Monitor the testbench results
$monitor("At time %t, a = %d, b = %d, cin = %b, sum = %d, cout = %b, {cout,sum} = %d",
$time, a, b, cin, sum, cout, {cout,sum});
end
endmodule
