`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Bryan Lai
// 
// Create Date:    19:48:42 01/09/2015 
// Design Name:    RISC CPU Design
// Module Name:    myCPU 
// Project Name:   MyCPU
// Target Devices: Xilinx Spartan 6
// Tool versions: 1.0
// Description:  5-level pipelines CPU design
//
// Dependencies: N/A
//
// Revision: N/A
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//*****************CPU state********************//
`define idle  	1'b0
`define exec  	1'b1

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

module myCPU(
input [15:0] d_datain,
input [15:0] i_datain,
input clock,
input reset,
input enable,
input start,
input [3:0] select_y,

output [7:0] d_addr,
output [7:0] d_dataout,
output [7:0] i_addr,
output d_we,
output [15:0] y
    );

//************* General Registers *************//
reg [15:0] gr[7:0];	
reg [7:0] pc;

//********** Stage Instruction Registers ******//
reg [15:0] id_ir;		//register for ID part
reg [15:0] ex_ir;		//register for EX part	
reg [15:0] mem_ir;	//register for MEM part
reg [15:0] wb_ir;		//register for WB part

//************** Stage Data Registers ********//
reg [15:0] reg_A, reg_B, smdr;	//ID Stage
reg [15:0] reg_C, smdr1; 			//EX Stage
reg dw,zf,nf,cf;						//EX Stage
reg [15:0] reg_C1;					//WB Stage

//************* CPU State Control *************//
reg state,next_state;

always @(posedge clock)
	begin
		if (!reset)
			state <= `idle;
		else
			state <= next_state;
	end
	
always @(*)
	begin
		case (state)
			`idle:
				if ((enable == 1'b1) 
				&& (start == 1'b1))
					next_state <= `exec;
				else	
					next_state <= `idle;
			`exec:
				if ((enable == 1'b0) 
				|| (wb_ir[15:11] == `HALT))
					next_state <= `idle;
				else
					next_state <= `exec;
		endcase
	end
	
//************* IF *************//
always @(posedge clock or negedge reset)
	begin
		if (!reset)
			begin
				id_ir <= 16'b0000_0000_0000_0000;
				pc <= 8'b0000_0000;
			end
			
		else if (state ==`exec)
			begin
				id_ir <= i_datain;
				
				if(((mem_ir[15:11] == `BZ) && (zf == 1'b1))
				|| ((mem_ir[15:11] == `BNZ) && (nf == 1'b0)
				|| ((mem_ir[15:11] == `BN) && (nf == 1'b1)))
				|| ((mem_ir[15:11] == `BNN) && (nf == 1'b0))
				|| ((mem_ir[15:11] == `BC) && (cf == 1'b1))
				|| ((mem_ir[15:11] == `BNC) && (cf == 1'b0))
				|| (mem_ir[15:11] == `JUMP) || (mem_ir[15:11] == `JMPR))
					pc <= reg_C[7:0];
				else
					pc <= pc + 1;
			end
end
	
	
//************* ID *************//
always @(posedge clock or negedge reset) begin
		if (!reset)
			begin
				ex_ir <= 16'b0000_0000_0000_0000;
				reg_A <= 16'b0000_0000_0000_0000;
				reg_B <= 16'b0000_0000_0000_0000;
				smdr  <= 16'b0000_0000_0000_0000;
			end
			
		else if (state == `exec)
			begin
				ex_ir <= id_ir;
			
				if ((id_ir[15:11] == `BZ) || (id_ir[15:11] == `BN)
				|| (id_ir[15:11] == `BNZ) || (id_ir[15:11] == `BNN)
				|| (id_ir[15:11] == `BC) || (id_ir[15:11] == `BNC)
				|| (id_ir[15:11] == `ADDI) || (id_ir[15:11] == `SUBI)
				|| (id_ir[15:11] == `LDIH)|| (id_ir[15:11] == `JMPR)
				|| (id_ir[15:11] == `JUMP))
					reg_A <= gr[(id_ir[10:8])];	//reg_A = operand 1 = gr[r1]
				else	
					reg_A <= gr[id_ir[6:4]];		//reg_A = operand 2 = gr[r2]
				
				if ((id_ir[15:11] == `LOAD) || (id_ir[15:11] == `SLL)
				|| (id_ir[15:11] == `SLA) || (id_ir[15:11] == `SRL)
				|| (id_ir[15:11] == `SRA))
					reg_B <= {12'b0000_0000_0000, id_ir[3:0]};	//reg_B = val3
				else if (id_ir[15:11] == `STORE)
					begin
						reg_B <= {12'b0000_0000_0000, id_ir[3:0]}; //reg_B = val3
						smdr <= gr[id_ir[10:8]];
					end
				else if ((id_ir[15:11] == `BZ) || (id_ir[15:11] == `BN)
				|| (id_ir[15:11] == `BNZ) || (id_ir[15:11] == `BNN)
				|| (id_ir[15:11] == `BC) || (id_ir[15:11] == `BNC)
				|| (id_ir[15:11] == `ADDI) || (id_ir[15:11] == `SUBI)
				|| (id_ir[15:11] == `LDIH) || (id_ir[15:11] == `JMPR)
				|| (id_ir[15:11] == `JUMP))
					reg_B <= {8'b0000_0000, id_ir[7:0]};		//reg_B = {val2,val3}
				else
					reg_B <= gr[id_ir[2:0]];						//reg_B = gr[r3]
			end
end
			
//************* EX *************//	
always @(posedge clock or negedge reset) begin
		if (!reset)
			begin
				mem_ir <= 16'b0000_0000_0000_0000;
				reg_C <= 16'b0000_0000_0000_0000;
				smdr1  <= 16'b0000_0000_0000_0000;
				dw <= 1'b0; zf <= 1'b0; nf <= 1'b0; cf <= 1'b0; 
			end
			
		else if (state == `exec)
				
			begin
				//ALU computation
				if ((ex_ir[15:11] == `LOAD) || (ex_ir[15:11] == `STORE) 
				|| (ex_ir[15:11] == `JMPR)  || (ex_ir[15:11] == `JUMP) 
				|| (ex_ir[15:11] == `BZ)    || (ex_ir[15:11] == `BNZ)
				|| (ex_ir[15:11] == `BN)	 || (ex_ir[15:11] == `BNN)
				|| (ex_ir[15:11] == `BC)	 || (ex_ir[15:11] == `BNC))
					begin
						reg_C <= reg_A + reg_B;
					end
					
				else if ((ex_ir[15:11] == `ADD)|| (ex_ir[15:11] == `ADDI)||(ex_ir[15:11] == `LDIH))
					begin
						{cf,reg_C} <= reg_A + reg_B;
					end
					
				else if ((ex_ir[15:11] == `SUB) || (ex_ir[15:11] == `SUBI)|| (ex_ir[15:11] == `CMP))
					begin
						{cf,reg_C} <= {1'b0,reg_A} - {1'b0,reg_B};
					end
				
				else if (ex_ir[15:11] == `AND)	
					begin
						reg_C <= reg_A & reg_B;
						cf <= 1'b0;
					end
				else if (ex_ir[15:11] == `OR)
					begin
						reg_C <= reg_A | reg_B;
						cf <= 1'b0;
					end
				else if (ex_ir[15:11] == `XOR)
					begin
						reg_C <= reg_A ^ reg_B;
						cf <= 1'b0;
					end
				else if (ex_ir[15:11] == `ADDC)
					begin
						{cf,reg_C} <= reg_A + reg_B + cf;
					end
				else if (ex_ir[15:11] == `SUBC)
					begin
						{cf,reg_C} <= {1'b0,reg_A} - {1'b0,reg_B} - cf;
					end
				else if ((ex_ir[15:11] == `SLL) || (ex_ir[15:11] == `SLA))
					begin
						{cf,reg_C[15:0]} <= {reg_A[15:0]} << reg_B[3:0];
					end
				else if (ex_ir[15:11] == `SRL)
					begin
						{reg_C[15:0],cf} <= {reg_A[15:0]} >> reg_B[3:0];
					end
				else if (ex_ir[15:11] == `SRA)
					begin
						{reg_C[15:0],cf} <= {reg_A[15:0]} >>> reg_B[3:0];
					end
					
				mem_ir <= ex_ir;
				
				//set the flags
				if ((ex_ir[15:11] == `ADD) || (ex_ir[15:11] == `ADDI)|| (ex_ir[15:11] == `ADDC)
				 || (ex_ir[15:11] == `SUB) || (ex_ir[15:11] == `SUBI)|| (ex_ir[15:11] == `SUBC)
				 || (ex_ir[15:11] == `AND) || (ex_ir[15:11] == `OR)  || (ex_ir[15:11] == `XOR)
				 || (ex_ir[15:11] == `SLL) || (ex_ir[15:11] == `SRL) || (ex_ir[15:11] == `SLA)
				 || (ex_ir[15:11] == `SRA) || (ex_ir[15:11] == `CMP) || (ex_ir[15:11] == `LDIH))
					begin
						if (reg_C == 16'b0000_0000_0000_0000) zf <= 1'b1;
						else											 zf <= 1'b0;
						
						if (reg_C[15] == 1'b1)					 nf <= 1'b1;
						else											 nf <= 1'b0;
					end
				else if (ex_ir[15:11] == `STORE)
					begin
						dw <= 1'b1;
						smdr1 <= smdr;
					end
				else
					dw <= 1'b0;
			end
end
			

//************* MEM *************//
always @(posedge clock or negedge reset) begin
		if (!reset)
			begin
				wb_ir  <= 16'b0000_0000_0000_0000;
				reg_C1 <= 16'b0000_0000_0000_0000; 
			end
			
		else if (state == `exec)
			begin
				wb_ir <= mem_ir;
				
				if (mem_ir[15:11] == `LOAD)
					reg_C1 <= d_datain;
				else
					reg_C1 <= reg_C;
			end
end
			
		
//************* WB *************//
always @(posedge clock or negedge reset) begin
		if (!reset)
			begin
				gr[0] = 16'b0000_0000_0000_0000; 
				gr[1] = 16'b0000_0000_0000_0000;
				gr[2] = 16'b0000_0000_0000_0000;
				gr[3] = 16'b0000_0000_0000_0000;
				gr[4] = 16'b0000_0000_0000_0000;
				gr[5] = 16'b0000_0000_0000_0000;
				gr[6] = 16'b0000_0000_0000_0000;
				gr[7] = 16'b0000_0000_0000_0000;
			end
			
		else if (state == `exec)
			begin
				if ((wb_ir[15:11] == `LOAD) || (wb_ir[15:11] == `SLL)
				|| (wb_ir[15:11] == `SLA) 	 || (wb_ir[15:11] == `SRL)
				|| (wb_ir[15:11] == `SRA)	 || (wb_ir[15:11] == `ADD)
				|| (wb_ir[15:11] == `ADDI)  || (wb_ir[15:11] == `SUB)
				|| (wb_ir[15:11] == `SUBI)	 || (wb_ir[15:11] == `AND)
				|| (wb_ir[15:11] == `OR)	 || (wb_ir[15:11] == `XOR)
				|| (wb_ir[15:11] == `LDIH)	 || (wb_ir[15:11] == `ADDC)
				|| (wb_ir[15:11] == `SUBC))
					gr[wb_ir[10:8]] <= reg_C1;
			end
end

endmodule
