`include "param.v"
`timescale 1ns/1ps

module DATA_HZ (
    // load use data hz
    input          exe_is_load_i      ,
    input [4:0]    id_rf_sr1_i        ,
    input [4:0]    id_rf_sr2_i        ,
    input [4:0]    exe_rf_wr_i        ,

    // other data hz
    input [31:0]   exe_rf_rd1_i       ,
    input [31:0]   exe_rf_rd2_i       ,
    input [4:0]    exe_rf_sr1_i       ,
    input [4:0]    exe_rf_sr2_i       ,
    // exe data hz 
    input          mem_rf_we_i        ,
    input [1:0]    mem_wb_sel_i       ,
    input [4:0]    mem_rf_wr_i        ,
    input [31:0]   mem_imme_i         ,
    input [31:0]   mem_alu_c_i        ,
    input [31:0]   mem_pc4_i          ,
    // mem stage
    input [4:0]    wb_rf_wr_i        ,
    input          wb_rf_we_i        ,
    input [1:0]    wb_wb_sel_i       ,
    input [31:0]   wb_imme_i         ,
    input [31:0]   wb_alu_c_i        ,
    input [31:0]   wb_pc4_i          ,
    input [31:0]   wb_dram_rd_i      ,

    // load use data hz
    output reg     pc_stall_o         ,
    output reg     if_id_stall_o      ,
    output reg     id_exe_flush_o     ,

    // other data hz
    output reg [31:0] exe_rd1_o           ,
    output reg [31:0] exe_rd2_o

);  
    /*
        load use data hz
    */ 
    always @(*) begin
        if (exe_is_load_i && (exe_rf_wr_i == id_rf_sr1_i
                || exe_rf_wr_i == id_rf_sr2_i))
            pc_stall_o = `CON_ENABLE;
        else 
            pc_stall_o = ~`CON_ENABLE; 
    end
    always @(*) begin
        if (exe_is_load_i && (exe_rf_wr_i == id_rf_sr1_i
                || exe_rf_wr_i == id_rf_sr2_i))
            if_id_stall_o = `CON_ENABLE;
        else 
            if_id_stall_o = ~`CON_ENABLE; 
    end
    always @(*) begin
        if (exe_is_load_i && (exe_rf_wr_i == id_rf_sr1_i
                || exe_rf_wr_i == id_rf_sr2_i))
            id_exe_flush_o = `CON_ENABLE;
        else 
            id_exe_flush_o = ~`CON_ENABLE; 
    end


    /*
        other data hz
    */ 

    assign exe1_hz = (mem_rf_wr_i == exe_rf_sr1_i 
                      && mem_rf_we_i 
                      && mem_rf_wr_i != 5'b0
                    ) ? 
                    `CON_ENABLE : ~`CON_ENABLE;
    
    assign exe2_hz = (mem_rf_wr_i == exe_rf_sr2_i 
                      && mem_rf_we_i 
                      && mem_rf_wr_i != 5'b0
                    ) ? 
                    `CON_ENABLE : ~`CON_ENABLE;

    assign mem1_hz = (wb_rf_wr_i == exe_rf_sr1_i
                     && wb_rf_we_i
                     && wb_rf_wr_i != 5'b0
                     ) ?
                     `CON_ENABLE : ~`CON_ENABLE;

    assign mem2_hz = (wb_rf_wr_i == exe_rf_sr2_i
                     && wb_rf_we_i
                     && wb_rf_wr_i != 5'b0
                     ) ?
                     `CON_ENABLE : ~`CON_ENABLE;

    always @(*) begin
        if(exe1_hz)
            case (mem_wb_sel_i)
                `SEXTDATA:  exe_rd1_o = mem_imme_i  ;
                `ALUCDATA:  exe_rd1_o = mem_alu_c_i ;
                `PC4DATA :  exe_rd1_o = mem_pc4_i   ;
                default  :  exe_rd1_o = 32'b0;
            endcase
        else if (mem1_hz)
            case (wb_wb_sel_i)
                `SEXTDATA:  exe_rd1_o = wb_imme_i     ;
                `ALUCDATA:  exe_rd1_o = wb_alu_c_i    ;
                `PC4DATA :  exe_rd1_o = wb_pc4_i      ;
                `DRAMDATA:  exe_rd1_o = wb_dram_rd_i  ;
                default  :  exe_rd1_o = 32'b0;
            endcase
        else 
            exe_rd1_o = exe_rf_rd1_i;
    end

    always @(*) begin
        if(exe2_hz)
            case (mem_wb_sel_i)
                `SEXTDATA:  exe_rd2_o = mem_imme_i  ;
                `ALUCDATA:  exe_rd2_o = mem_alu_c_i ;
                `PC4DATA :  exe_rd2_o = mem_pc4_i   ;
                default  :  exe_rd2_o = 32'b0;
            endcase
        else if (mem2_hz)
            case (wb_wb_sel_i)
                `SEXTDATA:  exe_rd2_o = wb_imme_i     ;
                `ALUCDATA:  exe_rd2_o = wb_alu_c_i    ;
                `PC4DATA :  exe_rd2_o = wb_pc4_i      ;
                `DRAMDATA:  exe_rd2_o = wb_dram_rd_i  ;
                default  :  exe_rd2_o = 32'b0;
            endcase
        else 
            exe_rd2_o = exe_rf_rd2_i;
    end









endmodule