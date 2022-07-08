`include "param.v"
`timescale 1ns / 1ps

module RF(
    input               rst_n_i,
    input               clk_i,
    input   [4:0]       rR1_i,
    input   [4:0]       rR2_i,
    input   [4:0]       wR_i,
    input               wE_i,
    // mul write data
    input   [1:0]       wd_sel_i,
    input   [31:0]      dram_rd_i,
    input   [31:0]      alu_c_i,
    input   [31:0]      npc_pc4_i,
    input   [31:0]      sext_ext_i,

    output  [31:0]      rD1_o,
    output  [31:0]      rD2_o,
    // just for trace
    output  [31:0]      wD_o
    );

    // register file
    reg [31:0] rf [31:0];

    wire rst = ~rst_n_i;

    // final write data
    reg [31:0] wd;

    assign wD_o = wd;

    // read x0
    assign rD1_o =  (rR1_i == 5'b0) ? 32'b0 : rf[rR1_i];
    assign rD2_o =  (rR2_i == 5'b0) ? 32'b0 : rf[rR2_i];

    //  reset and write data
    always @(posedge clk_i or posedge rst) begin
        if (rst) begin
            rf[0] <= 32'b0;
            rf[1] <= 32'b0;
            rf[2] <= 32'b0;
            rf[3] <= 32'b0;
            rf[4] <= 32'b0;
            rf[5] <= 32'b0;
            rf[6] <= 32'b0;
            rf[7] <= 32'b0;
            rf[8] <= 32'b0;
            rf[9] <= 32'b0;
            rf[10] <= 32'b0;
            rf[11] <= 32'b0;
            rf[12] <= 32'b0;
            rf[13] <= 32'b0;
            rf[14] <= 32'b0;
            rf[15] <= 32'b0;
            rf[16] <= 32'b0;
            rf[17] <= 32'b0;
            rf[18] <= 32'b0;
            rf[19] <= 32'b0;
            rf[20] <= 32'b0;
            rf[21] <= 32'b0;
            rf[22] <= 32'b0;
            rf[23] <= 32'b0;
            rf[24] <= 32'b0;
            rf[25] <= 32'b0;
            rf[26] <= 32'b0;
            rf[27] <= 32'b0;
            rf[28] <= 32'b0;
            rf[29] <= 32'b0;
            rf[30] <= 32'b0;
            rf[31] <= 32'b0;
        end else if (wE_i == `CON_ENABLE && wR_i != 32'b0) begin
            // write data
            rf[wR_i] <= wd;
        end
        else 
            rf[wR_i] <= rf[wR_i];
    end
     

    // select which data to write
    always @(*) begin
        case (wd_sel_i)
            `DRAMDATA:  
                wd = dram_rd_i;
            `ALUCDATA:
                wd = alu_c_i;
            `PC4DATA:
                wd = npc_pc4_i;
            `SEXTDATA: 
                wd = sext_ext_i;
            default: 
                wd = sext_ext_i;
        endcase
    end

endmodule
