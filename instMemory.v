`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:02:00 01/10/2015 
// Design Name: 
// Module Name:    instMemory 
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
module instMemory(
input [7:0] i_addr,
output reg [15:0] i_dataout
    );

reg [15:0] inst_mem [255:0];		//instruction memory

always @(posedge clock)  begin
	i_dataout <= inst_mem[i_addr];
end
endmodule
