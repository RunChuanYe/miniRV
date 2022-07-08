`include "param.v"
`timescale 1ns / 1ps



module PC(
    input               clk_i      ,
    input [31:0]        pc4_i      ,
    input [31:0]        alu_c_i    ,
    input               rst_n_i    ,
    input               pc_sel_i   , 
    // PC change enable
    input               stall_i    ,
    output  reg [31:0]  pc_o    
    );

    // // get
    // reg rst_n;
    // always @(posedge clk_i) begin
    //     rst_n <= rst_n_i;
    // end

    // npc 32 bits
    wire [31:0] npc = ((pc_sel_i == `CON_PC_SEL_PC4) ? pc4_i : alu_c_i);

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i)                   pc_o <= 32'b0;
        // else if (!rst_n)                pc_o <= 32'b0;
        else if (stall_i)               pc_o <= pc_o;
        else                            pc_o <= npc;
    end

endmodule
