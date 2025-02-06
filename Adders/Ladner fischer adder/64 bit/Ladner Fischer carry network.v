module carry_compine (
  input wire [1:0] g, p,
  output wire G, P
  );
  
  // Compute group propagate and generate signals
  assign P = &p[1:0]; // P = p1 & p0
  assign G = g[1] | (g[0] & p[1]); // G = g1 | (g0 & p1)
  
endmodule


module _2bit_Lander_fischer_network (
  input wire [1:0] g, p,
  output wire [1:0] G, P
  );

  // Compute 2-bit carry lookahead signals
  carry_compine cp1 (g[1:0], p[1:0], G[1], P[1]);
  
  assign G[0] = g[0];
  assign P[0] = p[0];
  
endmodule


module _4bit_Lander_fischer_network (
  input wire [3:0] g, p,
  output wire [3:0] G, P
  );
  
  wire [1:0] Gin, Pin;
  
  // Compute 4-bit carry lookahead signals using 2-bit networks
  _2bit_Lander_fischer_network lfn1 (g[1:0], p[1:0], G[1:0], P[1:0]);
  _2bit_Lander_fischer_network lfn2 (g[3:2], p[3:2], Gin[1:0], Pin[1:0]);

  // Compute final carry lookahead signals
  carry_compine cp1 ({Gin[0], G[1]}, {Pin[0], P[1]}, G[2], P[2]);
  carry_compine cp2 ({Gin[1], G[1]}, {Pin[1], P[1]}, G[3], P[3]);
  
endmodule


module _8bit_Lander_fischer_network (
  input wire [7:0] g, p,
  output wire [7:0] G, P
  );
  
  wire [3:0] Gin, Pin;
  
  // Compute 8-bit carry lookahead signals using 4-bit networks
  _4bit_Lander_fischer_network lfn1 (g[3:0], p[3:0], G[3:0], P[3:0]);
  _4bit_Lander_fischer_network lfn2 (g[7:4], p[7:4], Gin[3:0], Pin[3:0]);
  
  // Compute final carry lookahead signals
  carry_compine cp1 ({Gin[0], G[3]}, {Pin[0], P[3]}, G[4], P[4]);
  carry_compine cp2 ({Gin[1], G[3]}, {Pin[1], P[3]}, G[5], P[5]);
  carry_compine cp3 ({Gin[2], G[3]}, {Pin[2], P[3]}, G[6], P[6]);
  carry_compine cp4 ({Gin[3], G[3]}, {Pin[3], P[3]}, G[7], P[7]);
  
endmodule


module _16bit_Lander_fischer_network (
  input wire [15:0] g, p,
  output wire [15:0] G, P
  );
  
  wire [7:0] Gin, Pin;
  
  // Compute 16-bit carry lookahead signals using 8-bit networks
  _8bit_Lander_fischer_network lfn1 (g[7:0], p[7:0], G[7:0], P[7:0]);
  _8bit_Lander_fischer_network lfn2 (g[15:8], p[15:8], Gin[7:0], Pin[7:0]);
  
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : a
      carry_compine cp1 ({Gin[i], G[7]}, {Pin[i], P[7]}, G[8+i], P[8+i]);
    end
  endgenerate
  
endmodule


module _32bit_Lander_fischer_network (
  input wire [31:0] g, p,
  output wire [31:0] G, P
  );
  
  wire [15:0] Gin, Pin;
  
  // Compute 32-bit carry lookahead signals using 16-bit networks
  _16bit_Lander_fischer_network lfn1 (g[15:0], p[15:0], G[15:0], P[15:0]);
  _16bit_Lander_fischer_network lfn2 (g[31:16], p[31:16], Gin[15:0], Pin[15:0]);

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : a
      carry_compine cp1 ({Gin[i], G[15]}, {Pin[i], P[15]}, G[16+i], P[16+i]);
    end
  endgenerate
  
endmodule


module _64bit_Lander_fischer_network (
  input wire [63:0] g, p,
  output wire [63:0] G, P
  );
  
  wire [31:0] Gin, Pin;
  
  // Compute 64-bit carry lookahead signals using 32-bit networks
  _32bit_Lander_fischer_network lfn1 (g[31:0], p[31:0], G[31:0], P[31:0]);
  _32bit_Lander_fischer_network lfn2 (g[63:32], p[63:32], Gin[31:0], Pin[31:0]);

  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : a
      carry_compine cp1 ({Gin[i], G[31]}, {Pin[i], P[31]}, G[32+i], P[32+i]);
    end
  endgenerate
  
endmodule

  