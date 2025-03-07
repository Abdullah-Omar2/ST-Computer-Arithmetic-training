module CSA #(parameter N)
  (
  input wire [N-1:0] x,y,z,
  output wire [N-1:0] s,c
  );
  genvar i;
  assign s = x ^ y ^ z;
  assign c = (x & y) | (y & z)  | (z & x) ;
endmodule


module adder #(parameter N)
  (
  input wire [N-1:0] a,b,
  input wire cin,
  output wire [N-1:0] s,
  output wire cout
  );
  assign {cout,s}=a+b+cin;
endmodule



