`include "param.v"
`timescale 1ns / 1ps


module CONTROLLER(
    input [31:0]        inst_i          ,
    input               rst_n_i         ,

    output reg          rf_we_o         ,
    output [2:0]        sext_op_o       ,
    output              a_sel_o         ,
    output              b_sel_o         ,
    output [3:0]        alu_op_o        ,
    output              dram_we_o       ,
    output [2:0]        load_op_o       ,
    output [1:0]        save_op_o       ,
    output [1:0]        wb_sel_o        ,
    output              is_load_o       

    // for trace 
    // output reg          have_inst_o     
  
    );

    

    /*  
        pre process
    */ 
    wire [6:0]  opcode = inst_i[6:0];
    wire [2:0]  fun3 = inst_i[14:12];
    wire [6:0]  fun7 = inst_i[31:25];

    // jal ?
    wire is_jal = (opcode == `CON_JAL);
    // jalr ?
    wire is_jalr = (opcode == `CON_JALR);
    // auipc ?
    wire is_auipc = (opcode == `CON_AUIPC);
    // lui ?
    wire is_lui = (opcode == `CON_LUI);

    // b type inst ?
    wire is_b_type = (opcode == `CON_BTYPE);
    // s type inst ?
    wire is_s_type = (opcode == `CON_STYPE);
    // r type inst ?
    wire is_r_type = (opcode == `CON_RTYPE);
    // i type inst ? except load and jalr
    wire is_i_type = (opcode == `CON_ITYPE);
    // load type inst ?
    wire is_l_type = (opcode == `CON_LTYPE);
    
    // /*
    //     PC SEL PART
    // */ 

    // // which b inst 
    // wire b_type_beq = (fun3 == `CON_PC_SEL_BEQ);
    // wire b_type_bne = (fun3 == `CON_PC_SEL_BNE);
    // wire b_type_blt = (fun3 == `CON_PC_SEL_BLT);
    // wire b_type_bltu = (fun3 == `CON_PC_SEL_BLTU);
    // wire b_type_bge = (fun3 == `CON_PC_SEL_BGE);
    // wire b_type_bgeu = (fun3 == `CON_PC_SEL_BGEU);

    // wire b_type_jump = is_b_type && ((b_type_beq  & eq_i  ) || 
    //                                  (b_type_bne  & ~eq_i ) ||
    //                                  (b_type_blt  & lt_i  ) || 
    //                                  (b_type_bltu & lt_i  ) || 
    //                                  (b_type_bge  & ~lt_i ) ||
    //                                  (b_type_bgeu & ~lt_i ));

    // // pc sel
    // // 0 : pc + 4, 1 : alu_result
    // assign pc_sel_o = (is_jal || is_jalr || 
    //                 b_type_jump || inst_i != 32'b0) ? 
    //                 `CON_PC_SEL_ALU_C : `CON_PC_SEL_PC4;


    /*
        RF WE PART
    */ 

    // 1 : enable, 0 : disable
    // except B and S type inst, other types all need to write back

        always @(*) begin
        if (inst_i == 32'b0 || !rst_n_i)  
            rf_we_o = ~`CON_ENABLE;
        else if (is_b_type || is_s_type)      
            rf_we_o = ~`CON_ENABLE;
        else 
            rf_we_o = `CON_ENABLE; 
    end

    
    /*
        SEXT OP PART
    */ 
    reg [2:0] sext_type;
    assign sext_op_o = sext_type;

    always @(*) begin
        case (opcode)
            `CON_ITYPE:
                sext_type = `CON_SEXT_I_TYPE;
            `CON_JALR :
                sext_type = `CON_SEXT_I_TYPE;
            `CON_LTYPE:
                sext_type = `CON_SEXT_I_TYPE;
            `CON_STYPE:
                sext_type = `CON_SEXT_S_TYPE;
            `CON_BTYPE:
                sext_type = `CON_SEXT_B_TYPE;
            `CON_AUIPC:
                sext_type = `CON_SEXT_U_TYPE;
            `CON_LUI:
                sext_type = `CON_SEXT_U_TYPE;
            `CON_JAL:
                sext_type = `CON_SEXT_J_TYPE;
            default: 
                sext_type = `CON_SEXT_ERROR;
        endcase
    end

    /*
        ALU SEL PART
    */ 

    // a sel
    assign a_sel_o = (is_b_type || is_auipc || is_jal) ? 
                    `CON_ALU_SEL_A_PC : `CON_ALU_SEL_A_SR1;
    // b sel
    assign b_sel_o = (is_r_type) ? 
                    `CON_ALU_SEL_B_SR2 : `CON_ALU_SEL_B_IMM;

    /*
        ALU OP PART
    */ 

    reg [3:0] alu_op_tmp;
    assign alu_op_o = alu_op_tmp;

    always @(*) begin
        if ((is_r_type || is_i_type) && fun3 == `CON_ALU_OP_FUN3_AND) 
            alu_op_tmp = `AND;
        else if ((is_r_type || is_i_type) && fun3 == `CON_ALU_OP_FUN3_OR)
            alu_op_tmp = `OR;
        else if ((is_r_type || is_i_type) && fun3 == `CON_ALU_OP_FUN3_XOR)
            alu_op_tmp = `XOR;
        else if (is_r_type && fun3 == `CON_ALU_OP_FUN3_SUB && fun7[6:4] == `CON_ALU_OP_FUN7_SUB)
            alu_op_tmp = `SUB;
        else if ((is_r_type || is_i_type) && fun3 == `CON_ALU_OP_FUN3_SLT)
            alu_op_tmp = `SLT;
        else if ((is_r_type || is_i_type) && fun3 == `CON_ALU_OP_FUN3_SLTU)
            alu_op_tmp = `SLTU;
        else if ((is_r_type || is_i_type) && fun3 == `CON_ALU_OP_FUN3_SLL)
            alu_op_tmp = `SLL;
        else if ((is_r_type || is_i_type) && fun3 == `CON_ALU_OP_FUN3_SRA && fun7[6:4] == `CON_ALU_OP_FUN7_SRA)
            alu_op_tmp = `SRA;
        else if ((is_r_type || is_i_type) && fun3 == `CON_ALU_OP_FUN3_SRL && fun7[6:4] == `CON_ALU_OP_FUN7_SRL)
            alu_op_tmp = `SRL;
        else   
            alu_op_tmp = `ADD;
    end



    // /*  
    //     BRANCH PART
    // */ 

    // assign bra_un_o = (is_b_type && 
    //                 (fun3 == `CON_PC_SEL_BLTU || fun3 == `CON_PC_SEL_BGEU)) ?
    //                 `UNSIGNED : `SIGNED;

    /*
       DRAM WE PART         
    */ 
    
    assign dram_we_o = is_s_type ? `CON_ENABLE : ~`CON_ENABLE;


    /*
        LOAD OP PART
    */ 
    reg [2 : 0] load_op_tmp;
    assign load_op_o = load_op_tmp;
    always @(*) begin
        case (fun3)
            `CON_LOAD_OP_LB:    load_op_tmp = `LOADB;
            `CON_LOAD_OP_LBU:   load_op_tmp = `LOADBU;
            `CON_LOAD_OP_LH:    load_op_tmp = `LOADH;
            `CON_LOAD_OP_LHU:   load_op_tmp = `LOADHU;
            default:            load_op_tmp = `LOADW;
        endcase
    end

    /*
        SAVE OP PART
    */ 
    reg [1:0] save_op_tmp;
    assign save_op_o = save_op_tmp;
    always @(*) begin
        case (fun3)
            `CON_SAVE_OP_SB:
                save_op_tmp = `SAVEB;
            `CON_SAVE_OP_SH:
                save_op_tmp = `SAVEH;
            `CON_SAVE_OP_SW:
                save_op_tmp = `SAVEW; 
            default: 
                save_op_tmp = `SAVEW;
        endcase
    end


    /*
        WB SEL PART
    */ 

    reg [1:0] wb_sel_tmp;
    assign wb_sel_o = wb_sel_tmp;

    always @(*) begin
        if (is_jal || is_jalr) 
            wb_sel_tmp = `PC4DATA;
        else if (is_l_type)
            wb_sel_tmp = `DRAMDATA;
        else if (is_lui)
            wb_sel_tmp = `SEXTDATA;
        else 
            wb_sel_tmp = `ALUCDATA;
    end


    // /*
    //     ADR ADDER PART
    // */ 

    // always @(*) begin
    //     if (is_jal || is_b_type)
    //         adr_adder_op_o = `ADR_ADDER_PC;
    //     else 
    //         adr_adder_op_o = `ADR_ADDER_RF_RD1;
    // end

    /*
        HAVE INST PART        
    */ 

    // whethere need to write back?
    // except the b type and the s type, all need to write back. 

    // always @(*) begin
    //     if (inst_i == 32'b0 || !rst_n_i)  
    //         have_inst_o = ~`CON_ENABLE;
    //     else if (is_b_type || is_s_type)      
    //         have_inst_o = ~`CON_ENABLE;
    //     else 
    //         have_inst_o = `CON_ENABLE; 
    // end

    /*
        is load type ?
    */ 

    assign is_load_o = is_l_type;

endmodule
