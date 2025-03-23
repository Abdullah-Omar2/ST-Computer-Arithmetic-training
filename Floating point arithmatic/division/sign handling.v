module sign_handling (
  input sign_a, sign_b,
  output sign_res
  );
  
  assign sign_res = sign_a ^ sign_b;
  
endmodule
