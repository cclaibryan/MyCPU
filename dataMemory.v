`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:02:14 01/10/2015 
// Design Name: 
// Module Name:    dataMemory 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

/*pay attention that datain for memory is dataout for cpu, vise versa*/
module dataMemory(
input clock,
input d_we,
input [7:0] d_addr,
input [15:0] d_datain,

output [15:0] d_dataout
    );
	 
reg [15:0] data_mem [255:0];		//data memory

always @(posedge clock) begin
	if (d_we)  data_mem[d_addr] <= d_datain;	//write data
	else		  d_dataout <= data_mem[d_addr];	//read data
end
			
endmodule
