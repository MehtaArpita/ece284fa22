// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;


  wire [row*col -1 :0] valid_temp;
  wire [psum_bw*col*(row+1)-1 : 0] temp;
  reg [2*row-1:0] inst_w_temp;

  assign  temp[psum_bw*col*1-1 :0] = 0;
  
  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
        .clk(clk), 
        .out_s(temp[(psum_bw*col*(i+1))-1 : psum_bw*col*i]), 
        .in_w(in_w [bw*i-1 : bw*(i-1)]),
        .in_n(temp[psum_bw*col*i - 1 : psum_bw*col*(i-1)]), 
        .valid(valid_temp[col*i-1:col*(i-1)]), 
        .inst_w(inst_w_temp[2*i-1:2*(i-1)]), 
        .reset(reset)
      );
  end

  always @ (posedge clk) begin

   // inst_w flows to row0 to row7
    inst_w_temp <= {inst_w_temp[2*row-1: 2],inst_w}; 
  end

assign valid = valid_temp [row*col-1 : row*col-8];
assign out_s = temp[psum_bw*col*(row+1)-1 : psum_bw*col*row];

endmodule
