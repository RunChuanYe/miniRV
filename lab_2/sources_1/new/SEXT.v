`include "param.v"
`timescale 1ns / 1ps


module SEXT(
    input  [31:7]    imme_i     ,
    input  [2:0]     sext_op_i  ,
    output [31:0]    imme_o
    );

    wire [31:0] i_result;
    wire [31:0] s_result;
    wire [31:0] b_result;
    wire [31:0] j_result;
    wire [31:0] u_result;

    reg [31:0] imme_e_tmp;

    // I TYPE
    assign i_result = {{20{imme_i[31]}}, imme_i[31:20]};
    // S TYPE
    assign s_result = {{20{imme_i[31]}}, imme_i[31:25], imme_i[11:7]};
    // B TYPE
    assign b_result = {{20{imme_i[31]}}, imme_i[7], imme_i[30:25], imme_i[11:8], 1'b0};
    // J TYPE
    assign j_result = {{12{imme_i[31]}}, imme_i[19:12], imme_i[20], imme_i[30:21], 1'b0};
    // U TYPE
    assign u_result = imme_i[31:12] << 12;


    // select the output
    assign imme_o = imme_e_tmp;
    always @(*) begin
        case (sext_op_i)
            `CON_SEXT_I_TYPE:
                imme_e_tmp = i_result;
            `CON_SEXT_S_TYPE:
                imme_e_tmp = s_result;
            `CON_SEXT_B_TYPE:
                imme_e_tmp = b_result;
            `CON_SEXT_J_TYPE:
                imme_e_tmp = j_result;
            `CON_SEXT_U_TYPE:
                imme_e_tmp = u_result; 
            default: 
                imme_e_tmp = imme_e_tmp;
        endcase
    end




endmodule
