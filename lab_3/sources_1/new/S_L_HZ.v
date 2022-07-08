`include "param.v"
`timescale 1ns / 1ps

module S_L_HZ(
    input               wb_dram_we_i    ,
    input [15:2]        wb_dram_adr_i   ,
    input [31:0]        wb_dram_wd_i    ,
    
    input               mem_is_load_i   ,
    input [15:2]        mem_dram_adr_i  ,
    input [31:0]        mem_dram_rd_i   ,

    output reg [31:0]   mem_dram_rd_o
    );


    wire is_s_l_hz = (wb_dram_adr_i == mem_dram_adr_i 
                     && mem_is_load_i
                     && wb_dram_we_i
                     ) ? 
                     `CON_ENABLE : ~`CON_ENABLE;

    always @(*) begin
        if (is_s_l_hz)
            mem_dram_rd_o = wb_dram_wd_i;
        else 
            mem_dram_rd_o = mem_dram_rd_i;
    end









endmodule
