`timescale 1ns/1ps

module HuffmanDecoder (symbolLength, decodedData, ready, decodedData_valid, encodedData, load, clk, rst);


//Outputs
output  reg [31:0] decodedData;     //4 bits to represent 16 different data 
output  reg [3:0] symbolLength;    //4 bits to represrnt upto length 16.
output reg  ready;           //
output  	decodedData_valid; 		// signifies valid 32 bit valid decoded data to be sent to L0;

//Inputs
input [5:0] encodedData;     // 10 bits sliding window; equals the maximum length of encoded data
input       clk;             // Clock
input       rst;             // Active Low Reset
input      load;            // Load input data when asserted

reg [2:0] state;                   // FSM State
reg enable;                  // Enable signal to LUT
reg [3:0] symbol;                  // Symbol input to LUT -> Converts symbol to address for LUT
reg [5:0] upper_reg;
reg [2:0] valid_count;

//==============================================================
// Main State Machine
//==============================================================

always @(posedge clk ) begin
  if (!rst) begin
     upper_reg <= 10'b0;
     //lower_reg <= 10'b0;
     state <= 3'd0;
     enable <= 1'b0;
     symbol <= 5'b0;
     ready  <= 1'b1;
     symbolLength <= 4'd10;
     valid_count <= 3'd0;
  end // end if (!rst)
  else begin
  	   enable <= 1'b0;
  	   if (enable) begin 
  	   	valid_count <= valid_count + 1;
  	   	end
       case (state)
          3'd0: begin   // Load input data into lower register
	         if (load) begin
	         	upper_reg <= encodedData;
				//lower_reg <= encodedData;
	            state <= 3'd2;
	            symbolLength <= 4'd0;
	         end
	         else state <= 3'd0;
		 ready <= 1'b0;
	  end
	  'd2: begin   // Check if the 1 length code is contained in input  
	         if  (upper_reg[5]) begin
	              symbol <= 4'b0;
	              decodedData <= {decodedData[27:0],4'b0};
				  //upper_reg <= {upper_reg[4:0], lower_reg[5]};
		          //lower_reg <= {lower_reg[8:0], encodedData[9]};
				  state <= 'd0;
				  enable <= 1'b1;
	              ready <= 1'b1;
				  symbolLength <= 4'd1;

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
						decodedData <= {decodedData[27:0],4'd9};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				'b0101 :begin 
						symbol <= 4'd2 ;
						decodedData <= {decodedData[27:0],4'd2};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
			    'b0100 :begin 
						symbol <= 4'd1 ;
						decodedData <= {decodedData[27:0],4'd1};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				'b0011 :begin 
						symbol <= 4'd6 ;
						decodedData <= {decodedData[27:0],4'd6};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				'b0010 :begin 
						symbol <= 4'd5 ;
						decodedData <= {decodedData[27:0],4'd5};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd4;
						//upper_reg <= {upper_reg[1:0], lower_reg[5:2]};
		                //lower_reg <= {lower_reg[5:0], encodedData[9:6]};
						end
				'b0000 :begin 
						symbol <= 4'd10 ;
						decodedData <= {decodedData[27:0],4'd10};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd4;
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
		          decodedData <= {decodedData[27:0],4'd7};
		          enable <= 1'b1;
	                  state <= 'd0;    // -> Go back to checks for length 3 codes
		          ready <= 1'b1;
                          symbolLength <= 4'd5;
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
						decodedData <= {decodedData[27:0],4'd3};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				'b011001 :begin 
						symbol <= 4'd4 ;
						decodedData <= {decodedData[27:0],4'd4};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
			    'b000110 :begin 
						symbol <= 4'd8 ;
						decodedData <= {decodedData[27:0],4'd8};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				'b000111 :begin 
						symbol <= 4'd12 ;
						decodedData <= {decodedData[27:0],4'd12};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				'b000100 :begin 
						symbol <= 4'd14 ;
						decodedData <= {decodedData[27:0],4'd14};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				'b000101 :begin 
						symbol <= 4'd15 ;
						decodedData <= {decodedData[27:0],4'd15};
						enable <= 1'b1;
						state <= 'd0;
						ready <= 1'b1;
						symbolLength <= 4'd6;
						//upper_reg <= lower_reg;
		                //lower_reg <= {lower_reg[3:0], encodedData[9:4]};
						end
				endcase
	  		end

     endcase // end case statement
  end // end else 	
end // end always


assign decodedData_valid = ((valid_count == 3'd7) && enable) ? 1 : 0 ;

endmodule