`timescale 1ns / 1ps

// RISC-V 32-bit
//CE 222 L
//Labiba Ahmad-2024260
//Maimoona Saboor-2024270

module pc(
    input   clk,
    input   reset,
    input  [31:0] pc_in,
    output reg [31:0] pc_out
);
always @(posedge clk or posedge reset) begin
    if (reset) pc_out <= 0;
    else       pc_out <= pc_in;
end
endmodule


module adder(
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] sum
);
assign sum = a + b;
endmodule


module instruction_memory(
    input  [31:0] pc,
    input         reset,
    output [31:0] instruction_code
);

reg [7:0] Memory [0:63];

assign instruction_code = reset ? 32'd0 :
    {Memory[pc+3], Memory[pc+2], Memory[pc+1], Memory[pc]};
initial begin

    // addi x16, x0, 10        x16 = 10 (s0)
    Memory[3]  = 8'h00; Memory[2]  = 8'ha0; Memory[1]  = 8'h08; Memory[0]  = 8'h13;

    // addi x17, x0, 5         x17 = 5 (s1)
    Memory[7]  = 8'h00; Memory[6]  = 8'h50; Memory[5]  = 8'h08; Memory[4]  = 8'h93;

    // addi x18, x0, 20        x18 = 20 (s2)
    Memory[11] = 8'h01; Memory[10] = 8'h40; Memory[9]  = 8'h09; Memory[8]  = 8'h13;

    // addi x19, x0, 3         x19 = 3 (s3)
    Memory[15] = 8'h00; Memory[14] = 8'h30; Memory[13] = 8'h09; Memory[12] = 8'h93;

    // add  x5, x16, x17       x5 = 15 (t0)
    Memory[19] = 8'h01; Memory[18] = 8'h18; Memory[17] = 8'h02; Memory[16] = 8'hb3;

    // sub  x6, x16, x17       x6 = 5 (t1)
    Memory[23] = 8'h41; Memory[22] = 8'h18; Memory[21] = 8'h03; Memory[20] = 8'h33;

    // and  x7, x16, x17       x7 = 0 (t2)
    Memory[27] = 8'h01; Memory[26] = 8'h18; Memory[25] = 8'h73; Memory[24] = 8'hb3;

    // or   x28, x16, x17      x28 = 15 (t3)
    Memory[31] = 8'h01; Memory[30] = 8'h18; Memory[29] = 8'h6e; Memory[28] = 8'h33;

    // add  x29, x18, x19      x29 = 23 (t4)
    Memory[35] = 8'h01; Memory[34] = 8'h39; Memory[33] = 8'h0e; Memory[32] = 8'hb3;

    // sub  x30, x18, x19      x30 = 17 (t5)
    Memory[39] = 8'h41; Memory[38] = 8'h39; Memory[37] = 8'h0f; Memory[36] = 8'h33;

    // sw   x5, 0(x0)          Mem[0] = 15
    Memory[43] = 8'h00; Memory[42] = 8'h50; Memory[41] = 8'h20; Memory[40] = 8'h23;

    // lw   x31, 0(x0)         x31 = 15
    Memory[47] = 8'h00; Memory[46] = 8'h00; Memory[45] = 8'h2f; Memory[44] = 8'h83;

    // beq  x6, x0, -4         x6 = 5 so NOT taken
    Memory[51] = 8'hfe; Memory[50] = 8'h03; Memory[49] = 8'h0e; Memory[48] = 8'he3;

    // beq  x0, x0, -4         always taken (loop test)
    Memory[55] = 8'hfe; Memory[54] = 8'h00; Memory[53] = 8'h0e; Memory[52] = 8'he3;

end

endmodule

module register_file(
    input clk,
    input reset, 
    input RegWrite,

    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [31:0] write_data,

    output [31:0] read_data1,
    output [31:0] read_data2
);

    reg [31:0] regfile [31:0];
    integer i;

    always @ (posedge clk) begin
        if (reset)  begin
            for (i=0; i<32; i=i+1)
                regfile[i] <=0;
        end
        else if (RegWrite && write_reg != 5'd0) begin
            regfile[write_reg] <= write_data;
        end
    end

    assign read_data1 = regfile[read_reg1];
    assign read_data2 = regfile[read_reg2];

endmodule

module control(
    input [6:0] opcode,

    output reg ALUSrc,
	output reg MemtoReg,
	output reg RegWrite,
	output reg MemRead,
	output reg MemWrite,
	output reg Branch,
	output reg ALUOp1,
	output reg ALUOp0
);

always @(*) begin
    // Defaults
    ALUSrc    = 0;
    MemtoReg  = 0;
    RegWrite  = 0;
    MemRead   = 0;
    MemWrite  = 0;
    Branch    = 0;
    ALUOp1    = 0;
    ALUOp0    = 0;

    case (opcode)

        // R-type (add, sub)
        7'b0110011: begin
            ALUSrc   = 0;
            RegWrite = 1;
            ALUOp1   = 1;  
            ALUOp0   = 0;
        end

        // lw
        7'b0000011: begin
            ALUSrc   = 1;
            MemtoReg = 1;
            RegWrite = 1;
            MemRead  = 1;
        end

        // sw
        7'b0100011: begin
            ALUSrc   = 1;
            MemWrite = 1;
        end

        // beq
        7'b1100011: begin
            Branch = 1;
            ALUOp0 = 1; // SUB
        end

        // addi
        7'b0010011: begin
            ALUSrc   = 1;
            RegWrite = 1;
            ALUOp1   = 1;  
            ALUOp0   = 1;
        end

    endcase
end

endmodule

module imm_gen(
    input  [31:0] instruction,
    output reg [31:0] imm_out
);
always @(*) begin
    case (instruction[6:0])
        7'b0000011: imm_out = {{20{instruction[31]}}, instruction[31:20]};                    // I-type (lw)
        7'b0010011: imm_out = {{20{instruction[31]}}, instruction[31:20]};                    // I-type ALU
        7'b0100011: imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S-type (sw)
        7'b1100011: imm_out = {{20{instruction[31]}}, instruction[7],
                                 instruction[30:25], instruction[11:8], 1'b0};
        default:    imm_out = 32'd0;
    endcase
end
endmodule

// ALU control encoding:
//   0000 = AND
//   0001 = OR
//   0010 = ADD
//   0110 = SUB

module alu_control(
    input  [1:0] ALUOp,
    input  [6:0] funct7,
    input  [2:0] funct3,
    output reg [3:0] operation
);
always @(*) begin
    case (ALUOp)
        2'b00: operation = 4'b0010;   // lw/sw → ADD
        2'b01: operation = 4'b0110;   // beq → SUB
        2'b10: begin
            case ({funct7, funct3})
                10'b0000000000: operation = 4'b0010; // ADD
                10'b0100000000: operation = 4'b0110; // SUB
                10'b0000000111: operation = 4'b0000; // AND
                10'b0000000110: operation = 4'b0001; // OR
                default:        operation = 4'bxxxx;
            endcase
        end                                          // ← closes 2'b10 begin
        2'b11: operation = 4'b0010;   // I-type ALU (addi) → ADD
        default: operation = 4'bxxxx;
    endcase
end
endmodule


module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_ctrl,
    output reg [31:0] result,
    output zero
);
assign zero = (result == 32'd0);

always @(*) begin
    case (alu_ctrl)
        4'b0000: result = a & b;                                              // AND
        4'b0001: result = a | b;                                              // OR
        4'b0010: result = a + b;                                              // ADD
        4'b0110: result = a - b;                                              // SUB
        default: result = 32'd0;
    endcase
end
endmodule


module data_memory(
    input   clk,
    input   MemRead,
    input   MemWrite,
    input  [31:0] address,
    input  [31:0] write_data,
    output [31:0] read_data
);
reg [31:0] Memory [0:63];
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            Memory[i] = 0;
    end
assign read_data = MemRead ? Memory[address[31:2]] : 32'd0;

always @(posedge clk) begin
    if (MemWrite)
        Memory[address[31:2]] <= write_data;
end
endmodule

//Toplevel CPU
module cpu(
    input clk,
    input reset,
    output [31:0] pc_out
);

//PC logic 
wire [31:0] pc_in, pc_plus4, branch_target;
wire PCSrc;

wire [31:0] imm_out; 

adder pc_adder (
    .a(pc_out),
    .b(32'd4),
    .sum(pc_plus4));

adder br_adder (
    .a(pc_out),
    .b(imm_out),
    .sum(branch_target)); 

assign PCSrc = Branch & zero;
assign pc_in = PCSrc ? branch_target : pc_plus4;

pc pc1 (
    .clk(clk),
    .reset(reset),
    .pc_in(pc_in),
    .pc_out(pc_out));

//Instruction Fetch 
wire [31:0] instruction_code;
instruction_memory inst_mem (
    .pc(pc_out),
    .reset(reset),
    .instruction_code(instruction_code)
);

//instruction Decode fields 
wire [6:0] opcode   = instruction_code[6:0];
wire [4:0] rd       = instruction_code[11:7];
wire [2:0] funct3   = instruction_code[14:12];
wire [4:0] rs1      = instruction_code[19:15];
wire [4:0] rs2      = instruction_code[24:20];
wire [6:0] funct7   = instruction_code[31:25];

//Control signals
wire ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp0;

control ctrl (
    .opcode(opcode),
    .ALUSrc(ALUSrc), 
    .MemtoReg(MemtoReg), 
    .RegWrite(RegWrite),
    .MemRead(MemRead), 
    .MemWrite(MemWrite), 
    .Branch(Branch),
    .ALUOp1(ALUOp1), 
    .ALUOp0(ALUOp0)
);

//Register File
wire [31:0] read_data1, read_data2, write_back;
register_file reg_file (
    .clk(clk), 
    .reset(reset), 
    .RegWrite(RegWrite),
    .read_reg1(rs1), 
    .read_reg2(rs2), 
    .write_reg(rd),
    .write_data(write_back),
    .read_data1(read_data1), 
    .read_data2(read_data2)
);

//Immediate Generator
imm_gen ig (
    .instruction(instruction_code),
    .imm_out(imm_out));

//ALU Control
wire [3:0]  alu_ctrl;

alu_control alu_ctrl_unit (
    .ALUOp({ALUOp1, ALUOp0}), 
    .funct7(funct7),
    .funct3(funct3),
    .operation(alu_ctrl)    
);
//ALU 
wire [31:0] alu_result;
wire        zero;
wire [31:0] alu_b = ALUSrc ? imm_out : read_data2;

alu alu1 (
    .a(read_data1), 
    .b(alu_b),
    .alu_ctrl(alu_ctrl),
    .result(alu_result), 
    .zero(zero)
);

//Data Memory 
wire [31:0] mem_read_data;
data_memory dmem (
    .clk(clk), 
    .MemRead(MemRead), 
    .MemWrite(MemWrite),
    .address(alu_result), 
    .write_data(read_data2),
    .read_data(mem_read_data)
);

assign write_back = MemtoReg ? mem_read_data : alu_result;

endmodule

