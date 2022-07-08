`include "param.v"
`timescale 1ns / 1ps

module CONTROL_HZ(
    // possible adr
    input [31:0]        pc4_i           ,
    input [31:0]        alu_c_i         ,
    // whethere to jump
    input [31:0]        inst_i          ,
    input               eq_i            ,
    input               lt_i            ,

    output              bra_un_o        ,
    output reg          pc_sel_o        ,   
    output reg          if_id_flush_o   ,
    output reg          id_exe_flush_o

    );

    /*
        pre precess
    */ 

    wire [6:0]  opcode = inst_i[6:0];
    wire [2:0]  fun3 = inst_i[14:12];

    // jal ?
    wire is_jal = (opcode == `CON_JAL);
    // jalr ?
    wire is_jalr = (opcode == `CON_JALR);
    // b type inst ?
    wire is_b_type = (opcode == `CON_BTYPE);

    /*
        PC SEL PART
    */ 

    // which b inst 
    wire b_type_beq = (fun3 == `CON_PC_SEL_BEQ);
    wire b_type_bne = (fun3 == `CON_PC_SEL_BNE);
    wire b_type_blt = (fun3 == `CON_PC_SEL_BLT);
    wire b_type_bltu = (fun3 == `CON_PC_SEL_BLTU);
    wire b_type_bge = (fun3 == `CON_PC_SEL_BGE);
    wire b_type_bgeu = (fun3 == `CON_PC_SEL_BGEU);

    wire b_type_jump = is_b_type && ((b_type_beq  & eq_i  ) || 
                                     (b_type_bne  & ~eq_i ) ||
                                     (b_type_blt  & lt_i  ) || 
                                     (b_type_bltu & lt_i  ) || 
                                     (b_type_bge  & ~lt_i ) ||
                                     (b_type_bgeu & ~lt_i ));

    // pc sel
    // 0 : pc + 4, 1 : alu_result
    assign pc_sel_tmp = (is_jal || is_jalr || 
                    b_type_jump) ? 
                    `CON_PC_SEL_ALU_C : `CON_PC_SEL_PC4;

    /*  
        BRANCH PART
    */ 

    assign bra_un_o = (is_b_type && 
                    (fun3 == `CON_PC_SEL_BLTU || fun3 == `CON_PC_SEL_BGEU)) ?
                    `UNSIGNED : `SIGNED;

    always @(*) begin
        if (pc4_i != alu_c_i 
                && pc_sel_tmp == `CON_PC_SEL_ALU_C)
            pc_sel_o = `CON_PC_SEL_ALU_C;
        else
            pc_sel_o = `CON_PC_SEL_PC4;
    end

    always @(*) begin
        if (pc4_i != alu_c_i 
                && pc_sel_tmp == `CON_PC_SEL_ALU_C)
            if_id_flush_o = `CON_ENABLE;
        else
            if_id_flush_o = ~`CON_ENABLE;
    end

    always @(*) begin
        if (pc4_i != alu_c_i 
                && pc_sel_tmp == `CON_PC_SEL_ALU_C)
            id_exe_flush_o = `CON_ENABLE;
        else
            id_exe_flush_o = ~`CON_ENABLE;
    end


endmodule
