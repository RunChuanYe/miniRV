`timescale 1ns / 1ps

module IF_ID_REG(
    input               clk_i,
    input               rst_n_i,
    input               stall_i,
    input               flush_i,
    
    input               have_inst_i,
    input [31:0]        pc_i,
    input [31:0]        pc4_i,
    input [31:0]        inst_i,
    
    output reg          have_inst_o,
    output reg [31:0]   pc_o,
    output reg [31:0]   pc4_o,
    output reg [31:0]   inst_o
    );
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      pc_o <= 32'b0;
        else if(flush_i)  pc_o <= 32'b0;
        else if(stall_i)  pc_o <= pc_o;
        else              pc_o <= pc_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      pc4_o <= 32'b0;
        else if(flush_i)  pc4_o <= 32'b0;
        else if(stall_i)  pc4_o <= pc4_o;
        else              pc4_o <= pc4_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      inst_o <= 32'b0;
        else if(flush_i)  inst_o <= 32'b0;
        else if(stall_i)  inst_o <= inst_o;
        else              inst_o <= inst_i;
    end
    
    always @ (posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)      have_inst_o <= 32'b0;
        else if(flush_i)  have_inst_o <= 32'b0;
        else if(stall_i)  have_inst_o <= have_inst_o;
        else              have_inst_o <= have_inst_i;
    end

endmodule