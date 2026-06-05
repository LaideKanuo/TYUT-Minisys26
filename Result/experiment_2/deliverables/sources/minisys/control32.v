`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32 (
    input   [5:0]   Opcode,             // from ifetc32 instruction[31..26]
    input   [21:0]  Alu_resultHigh,     // from executs32 Alu_Result[31..10]
    input   [5:0]   Function_opcode,    // from ifetc32 r-type instructions[5..0]
    output          Jrn,                // 1: jr instruction
    output          RegDST,             // 1: dest reg is rd, 0: dest reg is rt
    output          ALUSrc,             // 1: second operand is immediate (except beq,bne)
    output          MemorIOtoReg,       // 1: data from memory or IO to register
    output          RegWrite,           // 1: write to register
    output          MemRead,            // 1: read from memory (not IO)
    output          MemWrite,           // 1: write to memory
    output          IORead,             // 1: read from IO
    output          IOWrite,            // 1: write to IO
    output          Branch,             // 1: beq instruction
    output          nBranch,            // 1: bne instruction
    output          Jmp,                // 1: j instruction
    output          Jal,                // 1: jal instruction
    output          I_format,           // 1: I-type except beq,bne,LW,SW
    output          Sftmd,              // 1: shift instruction
    output  [1:0]   ALUOp               // bit1: R-type or I_format, bit0: beq or bne
);

    wire R_format;      // 1: R-type instruction
    wire Lw;            // 1: lw instruction
    wire Sw;            // 1: sw instruction

    // IO address decode: 0xFFFFFCxx => Alu_resultHigh[21:0] == 22'h3FFFFF
    wire is_io;
    assign is_io = (Alu_resultHigh[21:0] == 22'h3FFFFF);

    assign R_format = (Opcode == 6'b000000) ? 1'b1 : 1'b0;
    assign RegDST = R_format;

    assign I_format = (Opcode[5:3] == 3'b001) ? 1'b1 : 1'b0;
    assign Lw = (Opcode == 6'b100011) ? 1'b1 : 1'b0;
    assign Jal = (Opcode == 6'b000011) ? 1'b1 : 1'b0;
    assign Jrn = (R_format && Function_opcode == 6'b001000) ? 1'b1 : 1'b0;
    // Fix: exclude JR from RegWrite (Bug #8)
    assign RegWrite = ((R_format && !Jrn) || I_format || Lw || Jal) ? 1'b1 : 1'b0;

    assign Sw = (Opcode == 6'b101011) ? 1'b1 : 1'b0;
    assign ALUSrc = (I_format || Lw || Sw) ? 1'b1 : 1'b0;
    assign Branch = (Opcode == 6'b000100) ? 1'b1 : 1'b0;
    assign nBranch = (Opcode == 6'b000101) ? 1'b1 : 1'b0;
    assign Jmp = (Opcode == 6'b000010) ? 1'b1 : 1'b0;

    // Memory vs IO split based on address
    assign MemWrite = (Sw && !is_io) ? 1'b1 : 1'b0;
    assign IOWrite  = (Sw &&  is_io) ? 1'b1 : 1'b0;
    assign MemRead  = (Lw && !is_io) ? 1'b1 : 1'b0;
    assign IORead   = (Lw &&  is_io) ? 1'b1 : 1'b0;

    assign MemorIOtoReg = Lw;
    assign Sftmd = (R_format && Function_opcode[5:3] == 3'b000) ? 1'b1 : 1'b0;

    assign ALUOp = {(R_format || I_format),(Branch || nBranch)};
endmodule
