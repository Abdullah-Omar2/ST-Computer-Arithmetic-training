module N_bit_carry_look_ahead #(parameter integer N = 64)(
  input wire cin,
  input wire [N-1:0] p, g,
  output wire [N:1] c,
  output wire P, G
);
  
  assign P= &p;
  
  genvar i;

  wire [N-1:0] temp_generate;
  assign temp_generate[0] = g[0];

  generate
    for (i = 1; i < N; i = i + 1) begin
      assign temp_generate[i] = g[i] | (p[i] & temp_generate[i-1]);
    end
  endgenerate

  assign G = temp_generate[N-1];
  
  assign c[1] = g[0] | (p[0] & cin); 
  generate
    for (i = 2; i < N+1; i = i + 1) begin
      assign c[i] = g[i-1] | (p[i-1]&c[i-1]);
    end
  endgenerate

endmodule


module N_bit_carry_look_ahead_tb;

  parameter N = 64;
  reg cin;
  reg [N-1:0] p, g;
  wire [N:1] c;
  wire P, G;
  reg [N:1] expected_c;

  N_bit_carry_look_ahead #(.N(N)) uut (cin, p, g, c, P, G);

  // Task to calculate expected carry
  task calculate_carry;
    input [N-1:0] p_in, g_in;
    input c_in;
    output [N:1] c_out;
    integer i;
    begin
      c_out[1] = g_in[0] | (p_in[0] & c_in);
      for (i = 1; i < N; i = i + 1) begin
        c_out[i+1] = g_in[i] | (p_in[i] & c_out[i]);
      end
    end
  endtask

  initial begin
    $monitor("Time=%0t | cin=%b | p=%016h | g=%016h | c=%016h | P=%b | G=%b", 
             $time, cin, p, g, c, P, G);

    // Test Case 1
    cin = 0; p = {N{1'b1}}; g = {N{1'b0}}; #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 1");

    // Test Case 2
    cin = 1; p = 64'hAA55AA55AA55AA55; g = 64'h55AA55AA55AA55AA; #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 2");

    // Test Case 3
    cin = 0; p = {N{1'b0}}; g = {N{1'b1}}; #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 3");

    // Test Case 4
    cin = 0; p = 0; g = 0; #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 4");

    // Test Case 5
    cin = 1; p = $urandom & {N{1'b1}}; g = $urandom & {N{1'b1}}; #10;
    calculate_carry(p, g, cin, expected_c);
    if (c !== expected_c) $display("ERROR in Test Case 5");

    $stop;
  end

endmodule
