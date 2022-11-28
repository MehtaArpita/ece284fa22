`timescale 1ns/1ps

module HuffmanDecoder (symbolLength, decodedData, ready, encodedData, load, clk, rst);


//Outputs
output  [3:0] decodedData;     //4 bits to represent 16 different data 
output  [3:0] symbolLength;    //4 bits to represrnt upto length 16.
output reg  ready;           //

//Inputs
input [5:0] encodedData;     // 10 bits sliding window; equals the maximum length of encoded data
input       clk;             // Clock
input       rst;             // Active Low Reset
input   reg load;            // Load input data when asserted

reg [2:0] state;                   // FSM State
reg enable;                  // Enable signal to LUT
reg [3:0] symbol;                  // Symbol input to LUT -> Converts symbol to address for LUT
reg [5:0] upper_reg;
reg [5:0] lower_reg;
reg [3:0] symbolLength_i;

//==============================================================
// Main State Machine
//==============================================================

always @(posedge clk ) begin
  if (!rst) begin
     upper_reg <= 10'b0;
     lower_reg <= 10'b0;
     state <= 3'd0;
     enable <= 1'b0;
     symbol <= 5'b0;
     ready  <= 1'b1;
     symbolLength_i <= 4'd10;
  end // end if (!rst)
  else begin
  	enable <= 0;
       case (state)
          3'd0: begin   // Load input data into lower register
	         if (load) begin
				lower_reg <= encodedData;
	            state <= 3'd1;
	         end
	         else state <= 3'd0;
		 ready <= 1'b1;
	  end
	  'd1: begin   // Load new data into lower register and old data upper register
	         if (load) begin
	            upper_reg <= lower_reg;
	            lower_reg <= encodedData;
	            state <= 3'd2;
	            symbolLength_i <= 4'd0;
	         end
	         else state <= 'd1;
		 ready <= 1'b0;
	  end
	  'd2: begin   // Check if the 1 length code is contained in input  
	         if  (upper_reg[5]) begin
	              symbol <= 4'b0;
				  //upper_reg <= {upper_reg[4:0], lower_reg[5]};
		          //lower_reg <= {lower_reg[8:0], encodedData[9]};
				  state <= 'd6;
				  enable <= 1'b1;
	              ready <= 1'b1;
				  symbolLength_i <= 4'd1;

		 end
		 else begin             // [8:7] == 2'b11 -> Go to checks for length 5 codes (First One)	               		   	          
	               state <= 'd3;    
				   ready <= 1'b0;
		 end
	  end
	  'd3: begin   // Check if the 4 length codes are contained in input  
	          case (upper_reg[5:2])
				'b0111 :begin 
						symbol <= 4'd9 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				'b0101 :begin 
						symbol <= 4'd2 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
			    'b0100 :begin 
						symbol <= 4'd1 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				'b0011 :begin 
						symbol <= 4'd6 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				'b0010 :begin 
						symbol <= 4'd5 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				'b0000 :begin 
						symbol <= 4'd10 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				default : begin  state <= 'd4;
						  ready <= 1'b0; end 
			  endcase


	  end
	  'd4: begin   // Check for the 5 length codes (Already have 011 checked till this point) 
	              if  (upper_reg[5:1] == 5'b01101) begin 
		          symbol <= 5'd7;  // M
		          enable <= 1'b1;
	                  state <= 'd6;    // -> Go back to checks for length 3 codes
		          ready <= 1'b1;
                          symbolLength_i <= 4'd5;
		          //upper_reg <= {upper_reg[0], lower_reg[5:1]};
		          //lower_reg <= {lower_reg[4:0], encodedData[9:5]};
		      end

	              else begin // (upper_reg[6:5] == 2'b10 or 2'b11)
	                  state <= 'd5;    // -> Go to checks for length 6 codes
		          ready <= 1'b0;
		      end
	  end
	  'd5: begin   // Check for the 6 length codes (Already have checked 0111 till thispoint) 

	          case (upper_reg[5:0])
				'b011000 :begin 
						symbol <= 4'd3 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				'b011001 :begin 
						symbol <= 4'd4 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
			    'b000110 :begin 
						symbol <= 4'd8 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				'b000111 :begin 
						symbol <= 4'd12 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				'b000100 :begin 
						symbol <= 4'd14 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				'b000101 :begin 
						symbol <= 4'd15 ;
						enable <= 1'b1;
						state <= 'd6;
						ready <= 1'b1;
						symbolLength_i <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				endcase
	  		end

	  'd6: begin   // Check if the 1 length code is contained in input  
	  		ready <= 1'b0; 
	        if (load == 1'b1) begin
				case (symbolLength_i)

	            4'b1 : begin 
	               	lower_reg <= {lower_reg[4:0], encodedData[5]};
	               	upper_reg <= {upper_reg[4:0], lower_reg[5]};
	               	state <= 'd2;
	               		end 
	            4'b0100 : begin 
	               	lower_reg <= {lower_reg[1:0], encodedData[5:2]};
	               	upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
	               	state <= 'd2;
	               		end 
	            4'b0101 : begin 
	               	lower_reg <= {lower_reg[0], encodedData[5:1]};
	               	upper_reg <= {upper_reg[0], lower_reg[5:1]};
	               	state <= 'd2;

	               		end 
	            4'b0110 : begin 
	               	lower_reg <= encodedData;
	               	upper_reg <= lower_reg;
	               	state <= 'd2;
	               		end 
				endcase
	         end
	         else state <= 'd6;
		 end 

     endcase // end case statement
  end // end else 	
end // end always


assign decodedData = symbol ; 
assign symbolLength = symbolLength_i ;
endmodule