`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2022 16:18:25
// Design Name: 
// Module Name: core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module core(clk, inst, ofifo_valid, D_xmem,D_rmem, activation_serial, decodedData_valid, sfp_out, reset);
    
  genvar i;
  genvar j;
 
  parameter col  = 8;
  parameter row  = 8;
  parameter bw = 4;
  parameter psum_bw = 16;  
  
  
  
  
 
 input clk;
 input reset;
 input [48:0] inst;
 input [31:0] D_xmem;
 input [psum_bw*col-1:0] D_rmem;
 input  activation_serial;
 output [psum_bw*col-1:0] sfp_out;
 output decodedData_valid;
 
 output ofifo_valid;

 
 wire [psum_bw*col-1:0] out_psum_SRAM; 
 wire [row*bw-1:0] Q;
 wire [row*bw-1:0] L0_in;
 wire [psum_bw*col-1:0] Q_rmem;
 wire [psum_bw*col-1:0] out_ofifo;

 /// hiffman decoder signals 
 reg load_encodeddata;
 reg[5:0] encodedData;
 reg [4:0]symbolLength;
 reg ready;
 
/*
assign inst_q[47] = CEN_rmem_q;
assign inst_q[46] = WEN_rmem_q;
assign inst_q[45:35] = A_rmem_q;
assign inst_q[34] = relu_q;
assign inst_q[33] = acc_q; // USED
assign inst_q[32] = CEN_pmem_q;  // USED
assign inst_q[31] = WEN_pmem_q;  // USED
assign inst_q[30:20] = A_pmem_q; // USED
assign inst_q[19]   = CEN_xmem_q; // USED
assign inst_q[18]   = WEN_xmem_q; // USED
assign inst_q[17:7] = A_xmem_q; // USED
assign inst_q[6]   = ofifo_rd_q; // USED
assign inst_q[5]   = ififo_wr_q;  //NO USE??
assign inst_q[4]   = ififo_rd_q; //NO USE??
assign inst_q[3]   = l0_rd_q; // USED
assign inst_q[2]   = l0_wr_q; // USED
assign inst_q[1]   = execute_q; // USED 
assign inst_q[0]   = load_q; // USED */
    
        
  sram_32b_w2048 L0_SRAM (                        
  .CLK(clk), 
  .CEN(inst[19]), 
  .WEN(inst[18]),
  .A(inst[17:7]), 
  .D(D_xmem), 
  .Q(Q));

  
    
    
    
    
  for (i=1; i < col+1 ; i=i+1) begin : row_num
    sram_16b_w2048 PSUM_SRAM (                        
        .CLK(clk), 
        .CEN(inst[32]), 
        .WEN(inst[31]),
        .A(inst[30:20]), 
        .D(out_ofifo[((i*psum_bw)-1):((i-1)*psum_bw)]), 
        .Q(out_psum_SRAM[((i*psum_bw)-1):((i-1)*psum_bw)]));
  end

  for (j=1; j < col+1 ; j=j+1) begin : row_number
    sram_16b_w2048 residual_SRAM (                        
        .CLK(clk), 
        .CEN(inst[47]), 
        .WEN(inst[46]),
        .A(inst[45:35]), 
        .D(D_rmem[((j*psum_bw)-1):((j-1)*psum_bw)]), 
        .Q(Q_rmem[((j*psum_bw)-1):((j-1)*psum_bw)]));
  end
    
  assign  L0_in = inst[35] ? decodedData : Q;
  assign  L0_wr = inst[35] ? decodedData_valid : inst[2]] ;
  corelet corelet_instance( 
  .clk(clk), 
  .acc(inst[33]), 
  .in_l0(L0_in), 
  .rd_ofifo(inst[6]), 
  .out_ofifo(out_ofifo), 
  .rd_l0(inst[3]), 
  .wr_l0(inst[L0_wr]),
  .out_psum_SRAM(out_psum_SRAM),
  //.full_l0(),
  //.ready_l0(),
  //.full_ofifo(),
  //.ready_ofifo(), 
  .valid_ofifo(ofifo_valid), 
  .inst_w(inst[1:0]),
  .sfp_out(sfp_out),
  .reset(reset),
  .relu(inst[34]),
  .r_mem(Q_rmem),
  .residual_add(inst[48]));  


  HuffmanDecoder i_HuffmanDecoder (
  .clk (clk),
  .rst (rst),
  .encodedData (encodedData),
  .load (load_encodeddata),
  .ready (ready),
  .decodedData (decodedData),
  .decodedData_valid (decodedData_valid),
  .symbolLength (symbolLength)
  );

  reg [401:0] input1 ; 

  /// controller code for huffman decoder 

    always @(posedge clk ) begin
   if (reset) begin
       load_encodeddata <= 1'b0;
       input1 <= 402'b0;
   end
   else if (inst[35]) begin
       if (ready == 1'b1) begin
          if (symbolLength == 4'd1)begin 
 
      encodedData[5:0] <= {encodedData[4:0], input1[401]};
      input1<= input1 <<1;
      end
      else if (symbolLength == 4'd4)begin 
              
      encodedData[5:0] <= {encodedData[1:0], input1[401:398]};
      input1<= input1 <<4;
      end 
     else if (symbolLength == 4'd5)begin 
              
      encodedData[5:0] <= {encodedData[0], input1[401:397]};
      input1<= input1 <<5;
      end 
     else if (symbolLength == 4'd6) begin   
      encodedData[5:0] <= input1[401:396];
      input1<= input1 <<6;
      end 
    else if (symbolLength == 4'd10) begin
        encodedData <= activation_serial[401:396];
        input1 <= {activation_serial[395:0],6'b0};
    end
    load_encodeddata <= 1'b1;
       end
       else
          load_encodeddata <= 1'b0;

   end //end else

end
    
endmodule