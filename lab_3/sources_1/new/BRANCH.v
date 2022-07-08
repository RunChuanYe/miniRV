`include "param.v"
`timescale 1ns / 1ps

module BRANCH(
    input [31:0]    sr1_i,
    input [31:0]    sr2_i,
    input           branch_un_i,
    output          eq_o,
    output          lt_o

    );

    // eq ?
    assign eq_o = ((sr1_i == sr2_i) ? 1'b1 : 1'b0);

    // lt ?
    // unsigned case
    wire lt_u = ((sr1_i < sr2_i) ? 1'b1 : 1'b0);

    // signed case
    // 1.sub op
    wire sub_signbit;
    wire [31:0] sub_result;
    wire [31:0] sr2_tmp = ~sr2_i[31:0] + 1'b1;

    assign {sub_signbit, sub_result} = {sr1_i[31], sr1_i} + 
                                        {sr2_tmp[31], sr2_tmp};

    // 2.judge the signed bit
    wire lt_s = ((sub_signbit == 1'b1) ? 1'b1 : 1'b0);

    assign lt_o = ((branch_un_i == `SIGNED) ? lt_s : lt_u);



endmodule
