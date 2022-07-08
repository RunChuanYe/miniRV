`include "param.v"
`timescale 1ns / 1ps


module ALU(
    input [31:0]      sr1_i,
    input [31:0]      sr2_i,
    input [31:0]      pc_i,
    input [31:0]      imm_i,
    input             num_a_sel_i,
    input             num_b_sel_i,
    input [ 3:0]      alu_op_i,
    output [31:0]     alu_c_o 
    );


    // op num 1
    wire [31:0] opNum_a;
    // op num 2
    wire [31:0] opNum_b;
    // tmp var for the output
    reg [31:0] output_tmp;

    // shamt
    wire [4:0] shamt = opNum_b[4:0];

    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] sra_result;
    wire [31:0] slt_u_result;
    wire [31:0] slt_result;

    // select the input op num_a and num_b 
    assign opNum_a = ((num_a_sel_i == `CON_ALU_SEL_A_SR1) ? sr1_i : pc_i );
    assign opNum_b = ((num_b_sel_i == `CON_ALU_SEL_B_SR2) ? sr2_i : imm_i);

    // add op 
    assign add_result = opNum_a + opNum_b;

    // sub op
    wire sub_signbit;
    wire [31:0] opNum2_tmp = ~opNum_b[31:0] + 1'b1;
    assign {sub_signbit, sub_result} = {opNum_a[31], opNum_a} + 
                                        {opNum2_tmp[31], opNum2_tmp};

    // or op
    assign or_result = opNum_a | opNum_b;
    
    // and op 
    assign and_result = opNum_a & opNum_b;

    // xor op
    assign xor_result = opNum_a ^ opNum_b;

    // slt_u op
    // if num_a < num_b then get 1
    // else get 0
    assign slt_u_result = ((opNum_a < opNum_b) ? 32'b01 : 32'b0);

    // sll op
    // using shamt
    assign sll_result = opNum_a << shamt;

    // srl op
    // using shamt
    assign srl_result = opNum_a >> shamt;

    // sra op
    // using shamt
    assign sra_result = $signed(opNum_a) >>> shamt;

    // slt op
    // if num_a >= num_b then get 1
    // else get 0
    assign slt_result = ((sub_signbit == 1'b1) ? 32'b1 : 32'b0);


    // select the output
    assign alu_c_o = output_tmp;
    always @(*) begin
        case (alu_op_i)
            `ADD:
                output_tmp = add_result;
            `SUB:
                output_tmp = sub_result;
            `AND:
                output_tmp = and_result;
            `OR:
                output_tmp = or_result;
            `SLTU:
                output_tmp = slt_u_result;
            `SLL:
                output_tmp = sll_result;
            `SRL:
                output_tmp = srl_result;
            `SRA:
                output_tmp = sra_result;
            `XOR:
                output_tmp = xor_result;
            `SLT:
                output_tmp = slt_result;
            default: 
                output_tmp = output_tmp;
        endcase
    end


    



endmodule
