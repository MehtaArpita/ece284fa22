`timescale 1ns/1ps

module HuffmanDecoder_tb (symbolLength, decodedData, ready, encodedData, load, clk, rst);

`define NULL 0

input [3:0] decodedData;  
input [3:0] symbolLength;  
input       ready;

output reg [5:0] encodedData;  
output reg       clk;  
output reg       rst;  
output reg       load; 

reg encodedData2;

initial begin
   clk = 1'b1;
   forever #10 clk = ~clk;
end

initial begin
   $dumpfile("decoding.vcd");
   $dumpvars(0,HuffmanDecoder_tb);

   rst = 1'b0;
   #45 rst = 1'b1;

$display(" finished");
#10000 $finish ;
end

reg[401:0] input1 = 402'b111111111111111111111111111111111111111111111111111111111010001011101001111110101111111101111111111000010010111111111111111111101010100111111111111111100111111111000010110111111111111111111110001111011000111110001011001111111000100101111001011101111011110001101111111111111111111011011011001101001110000100111111101111011011010111100101001110010111111111111111111111111111111111111111111111111111111111;
//reg[40:0] input1 = 41'b00001011111101111111011111111111101111111; 

//x_file = $fopen("huffman_VGG_data.txt", "r");
//x_scan_file = $fscanf(x_file,"%402b", input1);

always @(posedge clk ) begin
   if (!rst) begin
       load <= 1'b0;
   end
   else begin
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
		    encodedData <= input1[401:396];
			input1 <= input1<<6;
		end
		load <= 1'b1;
       end
       else
          load <= 1'b0;

   end //end else

end



//==============================================================
// Instantiate Design
//==============================================================
   HuffmanDecoder i_HuffmanDecoder (
                    .clk (clk),
				    .rst (rst),
				    .encodedData (encodedData),
				    .load (load),
				    .ready (ready),
		            .decodedData (decodedData),
		            .symbolLength (symbolLength)
       		                   );



endmodule
