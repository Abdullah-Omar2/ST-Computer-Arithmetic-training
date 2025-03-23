      
module Normalize (
  input [23:0] quotient,
  output [23:0] normalized,
  output adjustment
  );
  
  assign normalized = quotient[23]? quotient : (quotient<<1);
  
  assign adjustment = quotient[23]? 1'b0 : 1'b1;
  
  
endmodule
  
  
  
  