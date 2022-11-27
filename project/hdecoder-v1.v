`timescale 1ns/1ps

module HuffmanDecoder (symbolLength, decodedData, ready, encodedData, load, clk, rst);


//Outputs
output [3:0] decodedData;     //4 bits to represent 16 different data 
output reg [3:0] symbolLength;    //4 bits to represrnt upto length 16.
output reg [3:0] ready;           //

//Inputs
input [9:0] encodedData;     // 10 bits sliding window; equals the maximum length of encoded data
input       clk;             // Clock
input       rst;             // Active Low Reset
input       load;            // Load input data when asserted

reg [2:0] state;                   // FSM State
reg enable;                  // Enable signal to LUT
reg [3:0] symbol;                  // Symbol input to LUT -> Converts symbol to address for LUT
reg [9:0] upper_reg;
reg [9:0] lower_reg;

//==============================================================
// Main State Machine
//==============================================================

always @(posedge clk or negedge rst) begin
  if (!rst) begin
     upper_reg <= 10'b0;
     lower_reg <= 10'b0;
     state <= 3'd0;
     enable <= 1'b0;
     symbol <= 5'b0;
     ready  <= 1'b1;
     symbolLength <= 4'd10;
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
	            symbolLength <= 4'd0;
	         end
	         else state <= 'd1;
		 ready <= 1'b0;
	  end
	  'd2: begin   // Check if the 1 length code is contained in input  
	         if  (upper_reg[9]) begin
	         	if (ready) begin 
	              symbol <= 4'b0;
				  upper_reg <= {upper_reg[8:0], lower_reg[9]};
		          lower_reg <= {lower_reg[8:0], encodedData[9]};
				  state <= 'd2;
				  enable <= 1'b1;
				  ready <= 1'b0;
				 end 
				else begin 
				  ready <= 1'b1;
				  symbolLength <= 4'd1;
				 end 
		 end
		 else begin             // [8:7] == 2'b11 -> Go to checks for length 5 codes (First One)
	               state <= 'd3;    
				   ready <= 1'b0;
		 end
	  end
	  'd3: begin   // Check if the 4 length codes are contained in input  
	          case (upper_reg[9:6])
				'b0111 :begin 
		         	if (ready) begin 
						symbol <= 4'd9 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[5:0], lower_reg[9:6]};
		                lower_reg <= {lower_reg[5:0], encodedData[9:6]};
				  		ready <= 1'b0;
				 end 
				else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd4;
				 end 

				end
				'b0101 :begin 
		         	if (ready) begin 
						symbol <= 4'd2 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[5:0], lower_reg[9:6]};
		                lower_reg <= {lower_reg[5:0], encodedData[9:6]};
				  		ready <= 1'b0;
				 end 
				else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd4;
				 end 
				 end
			    'b0100 :begin 
		         	if (ready) begin 
						symbol <= 4'd1 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[5:0], lower_reg[9:6]};
		                lower_reg <= {lower_reg[5:0], encodedData[9:6]};
				  		ready <= 1'b0;
				 end 
				else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd4;
				 end 
				 end
				'b0011 :begin 
		         	if (ready) begin 
						symbol <= 4'd6 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[5:0], lower_reg[9:6]};
		                lower_reg <= {lower_reg[5:0], encodedData[9:6]};
				  		ready <= 1'b0;
				 end 
				else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd4;
				 end 
				 end
				'b0010 :begin 
		         	if (ready) begin 
						symbol <= 4'd5 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[5:0], lower_reg[9:6]};
		                lower_reg <= {lower_reg[5:0], encodedData[9:6]};
				  		ready <= 1'b0;
				 end 
				else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd4;
				 end 
				 end
				'b0000 :begin 
		         	if (ready) begin 
						symbol <= 4'd10 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[5:0], lower_reg[9:6]};
		                lower_reg <= {lower_reg[5:0], encodedData[9:6]};
				  		ready <= 1'b0;
				 end 
				else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd4;
				 end 
				 end
				default : begin  state <= 'd4;
						  ready <= 1'b0; end 
			  endcase
			  
			
	  end
	  'd4: begin   // Check for the 5 length codes (Already have 011 checked till this point) 
	              if  (upper_reg[9:5] == 5'b01101) begin 
	              	if (ready) begin 
						symbol <= 4'd7 ;
						enable <= 1'b1;
						state <= 'd2;
		          		upper_reg <= {upper_reg[4:0], lower_reg[9:5]};
		          		lower_reg <= {lower_reg[4:0], encodedData[9:5]};
				  		ready <= 1'b0;
				 	end 
					else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd5;
				 	end 
				  end
	              
	              else begin // (upper_reg[6:5] == 2'b10 or 2'b11)
	                  state <= 'd5;    // -> Go to checks for length 6 codes
		          	  ready <= 1'b0;
		      	  end
	  end
	  'd5: begin   // Check for the 6 length codes (Already have checked 0111 till this point) 
	            
	          case (upper_reg[9:4])
				'b011000 :begin 

		         	if (ready) begin 
						symbol <= 4'd3 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[3:0], lower_reg[9:4]};
		                lower_reg <= {lower_reg[3:0], encodedData[9:4]};
				  		ready <= 1'b0;
				 	end 
					else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd6;
				 	end 
				 end

				'b011001 :begin 
		         	if (ready) begin 
						symbol <= 4'd4 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[3:0], lower_reg[9:4]};
		                lower_reg <= {lower_reg[3:0], encodedData[9:4]};
				  		ready <= 1'b0;
				 	end 
					else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd6;
				 	end 
				 end

			    'b000110 :begin 
		         	if (ready) begin 
						symbol <= 4'd8 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[3:0], lower_reg[9:4]};
		                lower_reg <= {lower_reg[3:0], encodedData[9:4]};
				  		ready <= 1'b0;
				 	end 
					else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd6;
				 	end 
				 end
				'b000111 :begin 
		         	if (ready) begin 
						symbol <= 4'd12 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[3:0], lower_reg[9:4]};
		                lower_reg <= {lower_reg[3:0], encodedData[9:4]};
				  		ready <= 1'b0;
				 	end 
					else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd6;
				 	end 
				 end
				'b000100 :begin 
		         	if (ready) begin 
						symbol <= 4'd14 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[3:0], lower_reg[9:4]};
		                lower_reg <= {lower_reg[3:0], encodedData[9:4]};
				  		ready <= 1'b0;
				 	end 
					else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd6;
				 	end 
				 end
				'b000101 :begin 
		         	if (ready) begin 
						symbol <= 4'd15 ;
						enable <= 1'b1;
						state <= 'd2;
						upper_reg <= {upper_reg[3:0], lower_reg[9:4]};
		                lower_reg <= {lower_reg[3:0], encodedData[9:4]};
				  		ready <= 1'b0;
				 	end 
					else begin 
				  		ready <= 1'b1;
						symbolLength <= 4'd6;
				 	end 
				 end

			   endcase
	  end
	 
     endcase // end case statement
  end // end else 	
end // end always


assign decodedData = symbol ; 
endmodule
