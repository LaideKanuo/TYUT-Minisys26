`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32 (
	input			reset,				// 锟斤拷位锟脚猴拷(锟竭碉拷平锟斤拷效)
    input			clock,				// 时锟斤拷(23MHz)
	output	[31:0]	Instruction,		// 锟斤拷锟街革拷畹斤拷锟斤拷锟侥ｏ拷锟�
    output	[31:0]	PC_plus_4_out,		// (pc+4)锟斤拷执锟叫碉拷元
    input	[31:0]	Add_result,			// 锟斤拷锟斤拷执锟叫碉拷元,锟斤拷锟斤拷锟斤拷锟阶拷锟街�
    input	[31:0]	Read_data_1,		// 锟斤拷锟斤拷锟斤拷锟诫单元锟斤拷jr指锟斤拷锟矫的碉拷址
    input			Branch,				// 锟斤拷锟皆匡拷锟狡碉拷元
    input			nBranch,			// 锟斤拷锟皆匡拷锟狡碉拷元
    input			Jmp,				// 锟斤拷锟皆匡拷锟狡碉拷元
    input			Jal,				// 锟斤拷锟皆匡拷锟狡碉拷元
    input			Jrn,				// 锟斤拷锟皆匡拷锟狡碉拷元
    input			Zero,				// 锟斤拷锟斤拷执锟叫碉拷元
    output	[31:0]	opcplus4,			// JAL指锟斤拷专锟矫碉拷PC+4
    // ROM Pinouts
	output	[13:0]	rom_adr_o,			// 锟斤拷锟斤拷锟斤拷ROM锟斤拷元锟斤拷取指锟斤拷址
	input	[31:0]	Jpadr				// 锟接筹拷锟斤拷ROM锟斤拷元锟叫伙拷取锟斤拷指锟斤拷
);
    
    wire [31:0] PC_plus_4;
    reg [31:0] PC;
    reg [31:0] next_PC;		// 锟斤拷锟斤拷指锟斤拷锟絇C锟斤拷锟斤拷一锟斤拷锟斤拷PC+4)
    reg [31:0] opcplus4;
    
	// ROM Pinouts
	assign rom_adr_o = PC[15:2];
	assign Instruction = Jpadr;
    

	assign PC_plus_4[31:2] = PC[31:2] + 1'b1;
	assign PC_plus_4[1:0]  = 2'b00;
	assign PC_plus_4_out = PC_plus_4[31:0];

    always @* begin
        if (Jrn == 1'b1)
            next_PC = Read_data_1;
        else if (Branch == 1'b1 && Zero == 1'b1)
            next_PC = Add_result;
        else if (nBranch == 1'b1 && Zero == 1'b0)
            next_PC = Add_result;
        else if (Jmp == 1'b1)
            next_PC = {PC_plus_4[31:28], Instruction[25:0], 2'b00};
        else if (Jal == 1'b1)
            next_PC = {PC_plus_4[31:28], Instruction[25:0], 2'b00};
        else
            next_PC = PC_plus_4;
    end
    
   always @(negedge clock) begin
        if (reset == 1'b1) begin
            PC <= 32'h00000000;
            opcplus4 <= 32'h00000000;
        end else begin
            PC <= next_PC;
            opcplus4 <= PC_plus_4;
        end
   end
endmodule
