`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:15:28 01/11/2015
// Design Name:   myCPU
// Module Name:   E:/ISEProject/MyCPU/phase1Test.v
// Project Name:  MyCPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: myCPU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`define gr0 3'b000
`define gr1 3'b001
`define gr2 3'b010
`define gr3 3'b011
`define gr4 3'b100
`define gr5 3'b101
`define gr6 3'b110
`define gr7 3'b111

//*****************operation set********************//
`define NOP  	5'b00000
`define HALT  	5'b00001

`define LOAD  	5'b00010
`define STORE 	5'b00011

`define LDIH  	5'b10000

`define ADD  	5'b01000
`define ADDI  	5'b01001
`define ADDC  	5'b10001

`define SUB  	5'b01010
`define SUBI  	5'b01011
`define SUBC  	5'b10010

`define CMP  	5'b01100

`define AND  	5'b01101
`define OR  	5'b01110
`define XOR  	5'b01111

`define SLL  	5'b00100
`define SRL  	5'b00110
`define SLA  	5'b00101
`define SRA  	5'b00111

`define JUMP  	5'b11000
`define JMPR  	5'b11001

`define BZ  	5'b11010
`define BNZ  	5'b11011
`define BN  	5'b11100
`define BNN  	5'b11101
`define BC  	5'b11110
`define BNC  	5'b11111

module phase1Test;

	// Inputs
	reg [15:0] d_datain;
	reg [15:0] i_datain;
	reg clock;
	reg reset;
	reg enable;
	reg start;
	reg [3:0] select_y;

	// Outputs
	wire [7:0] d_addr;
	wire [7:0] d_dataout;
	wire [7:0] i_addr;
	wire d_we;
	wire [15:0] y;

	// Instantiate the Unit Under Test (UUT)
	myCPU uut (
		.d_datain(d_datain), 
		.i_datain(i_datain), 
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.start(start), 
		.select_y(select_y), 
		.d_addr(d_addr), 
		.d_dataout(d_dataout), 
		.i_addr(i_addr), 
		.d_we(d_we), 
		.y(y)
	);
	
	initial begin

		$display("pc:      id_ir     :regA:regB:regC:da:dd:w:reC1: gr1: gr2: gr3");
		$monitor("%h:%b:%h:%h:%h:%h:%h:%b:%h:%h:%h:%h",
			uut.pc, uut.id_ir, uut.reg_A, uut.reg_B,uut.reg_C,
			d_addr, d_dataout, d_we, uut.reg_C1, uut.gr[1], uut.gr[2], uut.gr[3]);
			
		enable <= 1; start <= 0; i_datain <= 0; d_datain <= 0; select_y <= 0; clock <= 0;
			
		#10 reset <= 0;
		#10 reset <= 1;
		#10 enable <= 1;
		#10 start <= 1;
		#10 i_datain <= {`LOAD, `gr1, 1'b0, `gr0, 4'b0000};	//LOAD gr1,gr0,0
		#10 i_datain <= {`LOAD, `gr2, 1'b0, `gr0, 4'b0001};	//LOAD gr2,gr0,1
		#10 i_datain <= {`NOP,11'b000_0000_0000};					//NOP
		#10 i_datain <= {`NOP,11'b000_0000_0000};					//NOP
			d_datain <= 16'h3CAB;										//3 clk later from LOAD
		#10 i_datain <= {`NOP,11'b000_0000_0000};					//NOP
			d_datain <= 16'h3C00;										//3 clk later from LOAD
		#10 i_datain <= {`SUB, `gr3, 1'b0, `gr1, 1'b0, `gr2}; //ADD gr3,gr1,gr2
		#10 i_datain <= {`NOP,11'b000_0000_0000};					//NOP
		#10 i_datain <= {`NOP,11'b000_0000_0000};					//NOP
		#10 i_datain <= {`NOP,11'b000_0000_0000};					//NOP
		#10 i_datain <= {`STORE,`gr3, 1'b0, `gr0, 4'b0010};	//STORE gr3,gr0,2
		#10 i_datain <= {`HALT,11'b000_0000_0000};				//HALT

	end
	
	always #5 clock = ~clock;
      
endmodule

