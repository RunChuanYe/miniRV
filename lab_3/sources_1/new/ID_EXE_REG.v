`timescale 1ns / 1ps

module ID_EXE_REG(
    input           clk_i               ,
    input           rst_n_i             ,
    input           ctrl_flush_i        ,
    input           data_flush_i        ,

    // trace
    input [31:0]        pc_i            ,
    input               have_inst_i     ,
    // control hz
    input [31:0]        inst_i          ,
    // rf
    input               rf_we_i         ,
    input [1:0]         wb_sel_i        ,
    input [31:0]        pc4_i           ,
    input [4:0]         rf_wr_i         ,
    input [4:0]         rf_sr1_i        ,
    input [4:0]         rf_sr2_i        ,
    // alu
    input               alu_a_sel_i     ,
    input               alu_b_sel_i     ,
    input [3:0]         alu_op_i        ,
    input [31:0]        rf_rd1_i        ,
    input [31:0]        imme_i          ,
    // alu/dram
    input [31:0]        rf_rd2_i        ,
    // dram
    input               dram_we_i       ,
    input [2:0]         load_op_i       ,
    input [1:0]         save_op_i       ,
    input               is_load_i       ,


    // trace
    output reg [31:0]        pc_o            ,
    output reg               have_inst_o     ,
    // control hz
    output reg [31:0]        inst_o          ,
    // rf
    output reg               rf_we_o         ,
    output reg [1:0]         wb_sel_o        ,
    output reg [31:0]        pc4_o           ,
    output reg [4:0]         rf_wr_o         ,
    output reg [4:0]         rf_sr1_o         ,
    output reg [4:0]         rf_sr2_o         ,
    // alu
    output reg               alu_a_sel_o     ,
    output reg               alu_b_sel_o     ,
    output reg [3:0]         alu_op_o        ,
    output reg [31:0]        rf_rd1_o        ,
    output reg [31:0]        imme_o          ,
    // alu/dram
    output reg [31:0]        rf_rd2_o        ,
    // dram
    output reg               dram_we_o       ,
    output reg [2:0]         load_op_o       ,
    output reg [1:0]         save_op_o       ,
    output reg               is_load_o       

    );

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      pc_o <= 32'b0;
        else if(data_flush_i || ctrl_flush_i)  pc_o <= 32'b0; 
        else              pc_o <= pc_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      have_inst_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) have_inst_o <= 32'b0;
        else              have_inst_o <= have_inst_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      inst_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) inst_o <= 32'b0;
        else              inst_o <= inst_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_we_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) rf_we_o <= 32'b0;
        else              rf_we_o <= rf_we_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      wb_sel_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) wb_sel_o <= 32'b0;
        else              wb_sel_o <= wb_sel_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      pc4_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) pc4_o <= 32'b0;
        else              pc4_o <= pc4_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_wr_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) rf_wr_o <= 32'b0;
        else              rf_wr_o <= rf_wr_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_sr1_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) rf_sr1_o <= 32'b0;
        else              rf_sr1_o <= rf_sr1_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_sr2_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) rf_sr2_o <= 32'b0;
        else              rf_sr2_o <= rf_sr2_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      alu_a_sel_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) alu_a_sel_o <= 32'b0;
        else              alu_a_sel_o <= alu_a_sel_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      alu_b_sel_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) alu_b_sel_o <= 32'b0;
        else              alu_b_sel_o <= alu_b_sel_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      alu_op_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) alu_op_o <= 32'b0;
        else              alu_op_o <= alu_op_i;
    end

    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_rd1_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) rf_rd1_o <= 32'b0;
        else              rf_rd1_o <= rf_rd1_i;
    end
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      imme_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) imme_o <= 32'b0;
        else              imme_o <= imme_i;
    end
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_rd2_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) rf_rd2_o <= 32'b0;
        else              rf_rd2_o <= rf_rd2_i;
    end
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      dram_we_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) dram_we_o <= 32'b0;
        else              dram_we_o <= dram_we_i;
    end
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      load_op_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) load_op_o <= 32'b0;
        else              load_op_o <= load_op_i;
    end
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      save_op_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) save_op_o <= 32'b0;
        else              save_op_o <= save_op_i;
    end
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      is_load_o <= 32'b0;
        else if (data_flush_i || ctrl_flush_i) is_load_o <= 32'b0;
        else              is_load_o <= is_load_i;
    end


endmodule
