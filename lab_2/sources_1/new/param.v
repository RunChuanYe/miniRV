// file: param.v
`ifndef CPU_PARAM
`define CPU_PARAM

    // syntax: `define <macro name> <parameter>

    /*
        ALU PARAM     
    */

    // ALU OP
    `define ADD     'b0000
    `define SUB     'b0001
    `define AND     'b0010
    `define OR      'b0011
    `define SLTU    'b0100
    `define SLL     'b0101
    `define SRL     'b0110
    `define SRA     'b0111
    `define XOR     'b1000
    `define SLT     'b1001

    /*
        BRANCH PARAM
    */ 

    `define UNSIGNED 1'b0
    `define SIGNED   1'b1


    /*
        WD in RF PARAM
    */ 
    `define SEXTDATA 2'b00
    `define DRAMDATA 2'b01
    `define ALUCDATA 2'b10
    `define PC4DATA  2'b11



    /*
        LOAD OP PARAM
    */ 
    `define LOADB   3'b000
    `define LOADBU  3'b001
    `define LOADH   3'b010
    `define LOADHU  3'b011
    `define LOADW   3'b100

    /*
        SAVE OP PARAM
    */ 
    `define SAVEB   2'b01
    `define SAVEH   2'b10
    `define SAVEW   2'b11



    /*
        CONTROLLER PARAM
    */ 

    // pc_sel
    `define CON_PC_SEL_PC4     1'b0
    `define CON_PC_SEL_ALU_C   1'b1
    
    // is jal
    `define CON_JAL      7'b1101111
    // is jalr
    `define CON_JALR     7'b1100111
    // is lui
    `define CON_LUI      7'b0110111
    // is auipc
    `define CON_AUIPC    7'b0010111
    
    // is B type
    `define CON_BTYPE     7'b1100011
    // is S type
    `define CON_STYPE     7'b0100011
    // is I type except load and jalr
    `define CON_ITYPE     7'b0010011
    // is R TYPE
    `define CON_RTYPE     7'b0110011
    // is Load TYPE ?
    `define CON_LTYPE     7'b0000011


    // which B type inst, using fun3 
    `define CON_PC_SEL_BEQ      3'b000
    `define CON_PC_SEL_BNE      3'b001
    `define CON_PC_SEL_BLT      3'b100
    `define CON_PC_SEL_BGE      3'b101
    `define CON_PC_SEL_BLTU     3'b110
    `define CON_PC_SEL_BGEU     3'b111
    
    // which Load type inst, using fun3
    `define CON_LOAD_OP_LB      3'b000
    `define CON_LOAD_OP_LBU     3'b100
    `define CON_LOAD_OP_LH      3'b001
    `define CON_LOAD_OP_LHU     3'b101
    `define CON_LOAD_OP_LW      3'b010

    // which save type inst, using fun3
    `define CON_SAVE_OP_SB      3'b000
    `define CON_SAVE_OP_SH      3'b001
    `define CON_SAVE_OP_SW      3'b010
    
    
  
    // alu op fun3
    `define CON_ALU_OP_FUN3_SUB     3'b000
    `define CON_ALU_OP_FUN3_AND     3'b111
    `define CON_ALU_OP_FUN3_OR      3'b110
    `define CON_ALU_OP_FUN3_XOR     3'b100
    `define CON_ALU_OP_FUN3_SLL     3'b001
    `define CON_ALU_OP_FUN3_SRL     3'b101
    `define CON_ALU_OP_FUN3_SRA     3'b101
    `define CON_ALU_OP_FUN3_SLT     3'b010
    `define CON_ALU_OP_FUN3_SLTU    3'b011

    // alu op fun7 highest 3 bits
    `define CON_ALU_OP_FUN7_SRL    3'b000
    `define CON_ALU_OP_FUN7_SRA    3'b010
    `define CON_ALU_OP_FUN7_SUB    3'b010



    // enable sign  
    `define CON_ENABLE          1'b1

    // sext op
    `define CON_SEXT_I_TYPE     3'b000
    `define CON_SEXT_S_TYPE     3'b001
    `define CON_SEXT_B_TYPE     3'b010
    `define CON_SEXT_U_TYPE     3'b011
    `define CON_SEXT_J_TYPE     3'b100
    `define CON_SEXT_ERROR      3'b101

    // alu sel a
    `define CON_ALU_SEL_A_PC    1'b0
    `define CON_ALU_SEL_A_SR1   1'b1
    // alu sel b
    `define CON_ALU_SEL_B_SR2   1'b0
    `define CON_ALU_SEL_B_IMM   1'b1



    `define STATE_IDLE 'b0001
    `define STATE_WRIT 'b0010
    `define STATE_WORK 'b0100
    `define STATE_RETU 'b1000

`endif