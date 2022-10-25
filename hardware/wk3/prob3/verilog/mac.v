// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

input [psum_bw-1:0] c; // signed input psum  
input [bw-1:0] a; // unsigned input 
input [bw-1:0 b;  //Signed weight  
output[psum_bw-1:0] out; // signed output psum 


out = $signed($signed(c) + (a*$signed(b)));


endmodule
