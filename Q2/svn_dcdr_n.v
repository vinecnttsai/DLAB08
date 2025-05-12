module svn_dcdr_n (
    input [3:0] in,
    input clk,
    input sys_rst_n,
    output CA, CB, CC, CD, CE, CF, CG,
    output DP,
    output [7:0] AN
);

svn_dcdr svn1 (
    .in(in),
    .CA(CA),
    .CB(CB),
    .CC(CC),
    .CD(CD),
    .CE(CE),
    .CF(CF),
    .CG(CG),
    .DP(DP)
);

shift_reg #(8, 1) display_shift (
    .sys_rst_n(sys_rst_n),
    .clk(clk),
    .enable(1'b1),
    .in(8'b11_111_110),
    .init(8'b11_111_110),
    .load(1'b0),
    .dir(1'b1),
    .out(AN)
);

endmodule

module svn_dcdr (
  input [3:0] in,
  output CA, CB, CC, CD, CE, CF, CG,
  output DP
);

assign {CA, CB, CC, CD, CE, CF, CG, DP} = 
  (in == 4'h0) ? 8'b00000011 :
  (in == 4'h1) ? 8'b10011111 :
  (in == 4'h2) ? 8'b00100101 :
  (in == 4'h3) ? 8'b00001101 :
  (in == 4'h4) ? 8'b10011001 :
  (in == 4'h5) ? 8'b01001001 :
  (in == 4'h6) ? 8'b01000001 :
  (in == 4'h7) ? 8'b00011111 :
  (in == 4'h8) ? 8'b00000001 :
  (in == 4'h9) ? 8'b00001001 :
  (in == 4'ha) ? 8'b11100101 :
  (in == 4'hb) ? 8'b11111101 :
  (in == 4'hc) ? 8'b10111001 :
  (in == 4'hd) ? 8'b11111101 :
  (in == 4'he) ? 8'b11000001 :
  8'b11111111;

endmodule
