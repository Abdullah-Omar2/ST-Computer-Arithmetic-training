module four_bit_carry_look_ahead 
  (
  input wire cin,                // Carry input (cin)
  input wire [3:0] p,            // Propagate signal (p)
  input wire [3:0] g,            // Generate signal (g)
  output wire [4:1] c,           // Carry signals (c)
  output wire P,                 // Propagate signal for the entire 4 bits
  output wire G                  // Generate signal for the entire 4 bits
  );
  
  // Calculate the overall propagate signal (P) for the 4 bits
  assign P = &p;  // P is the AND of all p bits
  
  // Calculate the overall generate signal (G) for the 4 bits
  assign G = g[3] | (g[2] & p[3]) | (g[1] & &p[3:2]) | (g[0] & &p[3:1]);

  // Calculate the individual carry signals based on the generate and propagate signals
  assign c[1] = g[0] | (p[0] & cin);               // Carry out of bit 0
  assign c[2] = g[1] | (p[1] & c[1]);               // Carry out of bit 1
  assign c[3] = g[2] | (p[2] & c[2]);               // Carry out of bit 2
  assign c[4] = g[3] | (p[3] & c[3]);               // Carry out of bit 3 (final carry)
  
endmodule

// Testbench for the four-bit carry look-ahead adder
module four_bit_carry_look_ahead_tb;

  reg cin;                     // Carry input signal
  reg [3:0] p, g;              // Propagate and generate signals
  wire [4:1] c;                // Carry outputs
  wire P, G;                   // Propagate and generate outputs

  // Instantiate the four-bit carry look-ahead adder
  four_bit_carry_look_ahead uut (cin, p, g, c, P, G);

  // Monitor and display the values of signals during simulation
  initial begin
    $monitor("Time: %0dns, cin: %b, p: %04b, g: %04b, c: %04b, P: %b, G: %b", $time, cin, p, g, c, P, G);
  end

  integer i, j;  // Loop variables for test vectors
  initial begin
    // Generate all combinations of propagate and generate inputs (p, g)
    for (i = 0; i < 16; i = i + 1) begin  // Loop through all 16 combinations of p
      for (j = 0; j < 16; j = j + 1) begin  // Loop through all 16 combinations of g
        // Test with cin = 0
        cin = 1'b0; 
        p = i;        // Assign current value of p
        g = j;        // Assign current value of g
        #10;          // Wait for 10 time units

        // Test with cin = 1
        cin = 1'b1; 
        #10;          // Wait for 10 time units
      end
    end

    // End the simulation
    $stop;
  end

endmodule


