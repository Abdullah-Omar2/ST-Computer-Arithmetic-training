module sign_handling (
  input sign_a,    // Sign bit of operand A
  input sign_b,    // Sign bit of operand B
  output sign_res  // Resulting sign bit
);
  
  // XOR operation to determine the sign of the result
  assign sign_res = sign_a ^ sign_b;
  
endmodule