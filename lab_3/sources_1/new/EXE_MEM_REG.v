`timescale 1ns / 1ps
module EXE_MEM_REG(
    input           clk_i           ,
    input           rst_n_i         ,

    // trace
    input [31:0]        pc_i        ,
    input               have_inst_i ,

    // dram
    input [2:0]         load_op_i   ,
    input [1:0]         save_op_i   ,
    input               dram_we_i   ,
    input [31:0]        rf_rd2_i    ,   //data in
    input [31:0]        alu_c_i     ,   //adr

    // wb
    input [31:0]        pc4_i       ,
    input [31:0]        imme_i      ,
    input [1:0]         wb_sel_i    ,
    input               rf_we_i     ,
    input [4:0]         rf_wr_i     ,
    // s_l_hz
    input               is_load_i   ,

    // trace
    output reg [31:0]        pc_o        ,
    output reg               have_inst_o ,

    // dram
    output reg [2:0]         load_op_o   ,
    output reg [1:0]         save_op_o   ,
    output reg               dram_we_o   ,
    output reg [31:0]        rf_rd2_o    ,   //data in
    output reg [31:0]        alu_c_o     ,   //adr

    // wb
    output reg [31:0]        pc4_o       ,
    output reg [31:0]        imme_o      ,
    output reg [1:0]         wb_sel_o    ,
    output reg               rf_we_o     ,
    output reg [4:0]         rf_wr_o     ,
    // s_l_hz
    output reg              is_load_o                  
    );

    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      pc_o <= 32'b0;
        else              pc_o <= pc_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      have_inst_o <= 32'b0;
        else              have_inst_o <= have_inst_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      load_op_o <= 32'b0;
        else              load_op_o <= load_op_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      save_op_o <= 32'b0;
        else              save_op_o <= save_op_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      dram_we_o <= 32'b0;
        else              dram_we_o <= dram_we_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_rd2_o <= 32'b0;
        else              rf_rd2_o <= rf_rd2_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      alu_c_o <= 32'b0;
        else              alu_c_o <= alu_c_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      pc4_o <= 32'b0;
        else              pc4_o <= pc4_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      imme_o <= 32'b0;
        else              imme_o <= imme_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      wb_sel_o <= 32'b0;
        else              wb_sel_o <= wb_sel_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_we_o <= 32'b0;
        else              rf_we_o <= rf_we_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      rf_wr_o <= 32'b0;
        else              rf_wr_o <= rf_wr_i;
    end
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      is_load_o <= 32'b0;
        else              is_load_o <= is_load_i;
    end

endmodule
