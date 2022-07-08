`timescale 1ns / 1ps


module miniRV(
    // 100MHz clk from board
    input   clk_i                   ,        
    // reset signal from board
    input   rst_n_i                 ,
    // irom
    output [31:0]   pc_o            ,
    input  [31:0]   inst_i          ,
    // dram
    output [31:0]   adr_o           ,
    output          we_o            ,
    output [31:0]   write_data_o    ,

    output [ 2:0]   load_op_o       ,
    output [ 1:0]   save_op_o       ,
    
    input  [31:0]   read_data_i     ,
    // dram end

    // s_l_hz
    input  [31:0]   sl_wb_wd_i      ,
    input  [31:0]   sl_mem_rd_i     ,
    output [31:0]   sl_mem_rd_o     ,

    // trace
    output          debug_wb_have_inst  ,
    output [31:0]   debug_wb_pc         ,
    output          debug_wb_ena        ,
    output [4:0]    debug_wb_reg        ,
    output [31:0]   debug_wb_value      
 
    );

    wire [31:0]     pc;
    wire [31:0]     pc4 = pc + 4;
    wire            pc_sel;
    wire            pc_stall;


    // IF_ID_REG
    wire            if_id_stall;
    wire            if_id_flush;
    wire [31:0]     if_id_pc;
    wire [31:0]     if_id_pc4;
    wire [31:0]     if_id_inst;
    wire            if_id_have_inst;
    // IF_ID_REG NED

    // ID_EXE_REG
    wire            id_exe_flush_data;
    wire            id_exe_flush_ctrl;
    wire            id_exe_have_inst;
    wire [31:0]     id_exe_pc;
    
    wire [31:0]     id_exe_inst;
    
    wire            id_exe_rf_we;
    wire [1:0]      id_exe_wb_sel;    
    wire [31:0]     id_exe_pc4;    
    wire [4:0]      id_exe_rf_wr;
    wire [4:0]      id_exe_rf_sr1;
    wire [4:0]      id_exe_rf_sr2;

    wire            id_exe_alu_a_sel;
    wire            id_exe_alu_b_sel;
    wire [3:0]      id_exe_alu_op;
    wire [31:0]     id_exe_rf_rd1;
    wire [31:0]     id_exe_imme;

    wire [31:0]     id_exe_rf_rd2;
    wire            id_exe_dram_we;
    wire [2:0]      id_exe_load_op;
    wire [1:0]      id_exe_save_op;
    wire            exe_is_load;
    wire            id_is_load;
    // ID_EXE_REG END

    // EXE_MEM_REG
    wire [31:0]        exe_mem_pc;
    wire               exe_mem_hava_inst;    
  
    wire [2:0]         exe_mem_load_op;
    wire [1:0]         exe_mem_save_op;
    wire               exe_mem_dram_we;
    wire [31:0]        exe_mem_rf_rd2;
    wire [31:0]        exe_mem_alu_c;

    wire [31:0]        exe_mem_imme;
    wire [31:0]        exe_mem_pc4;
    wire [1:0]         exe_mem_wb_sel;
    wire               exe_mem_rf_we;
    wire [4:0]         exe_mem_rf_wr;

    // s_l_hz
    wire               exe_mem_is_load;

    // EXE_MEM_REG END

    // MEM_WB_REG
    wire [31:0]        mem_wb_pc        ;    
    wire               mem_wb_have_inst ;         

    wire [31:0]        mem_wb_pc4       ;
    wire [31:0]        mem_wb_imme      ;
    wire [31:0]        mem_wb_alu_c     ;
    wire [31:0]        mem_wb_dram_rd   ;

    wire [1:0]         mem_wb_wb_sel    ;
    wire               mem_wb_rf_we     ; 
    wire [4:0]         mem_wb_rf_wr     ;

    // s_l_hz
    wire               mem_wb_dram_we   ;
    wire [15:2]        mem_wb_dram_adr  ;
    wire [31:0]        mem_wb_dram_wd   ;
    // MEM_WB_REG END

    wire [4:0]      rf_rR1 = if_id_inst[19:15];
    wire [4:0]      rf_rR2 = if_id_inst[24:20];
    wire [4:0]      rf_wR  = if_id_inst[11:7 ];
    wire            rf_we;
    wire [1:0]      rf_wd_sel;
    wire [31:0]     rf_rd1;
    wire [31:0]     rf_rd2;

    wire [31:7]     imme = if_id_inst[31:7];
    wire [2:0]      sext_op;
    wire [31:0]     imme_o;
    
    wire            branch_un;
    wire            beq;
    wire            blt;

    wire            have_inst = 1'b1;


    wire            num_a_sel;
    wire            num_b_sel;
    wire [3:0]      alu_op;
    wire [31:0]     alu_c;

    wire [ 2:0]     load_op;
    wire [ 1:0]     save_op;
    wire            dram_we;

    // adr adder
    // wire [31:0]     adr_adder_res;
    // wire            adr_adder_op;

    // control hz
    wire            pc_sel_hz;
    // data hz
    wire [31:0]     rd1_hz;
    wire [31:0]     rd2_hz;

    // irom adr
    assign          pc_o = pc;
    // device adr
    assign          adr_o = exe_mem_alu_c;
    // device write enable
    assign          we_o = exe_mem_dram_we;
    // write data
    assign          write_data_o = exe_mem_rf_rd2;
    // load op
    assign          load_op_o = exe_mem_load_op;
    // save op
    assign          save_op_o = exe_mem_save_op; 

    // trace
    wire [31:0]     rf_wb_value;

    assign debug_wb_have_inst = mem_wb_have_inst;
    assign debug_wb_pc = mem_wb_pc;
    assign debug_wb_reg = mem_wb_rf_wr;
    assign debug_wb_ena = mem_wb_rf_we;
    assign debug_wb_value = rf_wb_value;  



    // *********   IF    ****************

    PC u_pc(
        .clk_i      (clk_i          ),
        .rst_n_i    (rst_n_i        ),
        
        .pc4_i      (pc4            ),
        .alu_c_i    (alu_c          ),
        .pc_sel_i   (pc_sel_hz      ),
        .stall_i    (pc_stall       ),

        .pc_o       (pc             )
    );
    


    // irom
    // ...

    // *********   IF    ****************

    IF_ID_REG u_if_id_reg(
        .clk_i       (clk_i              ),
        .rst_n_i     (rst_n_i            ),
        .stall_i     (if_id_stall        ),
        .flush_i     (if_id_flush        ),
        .have_inst_i (have_inst          ),
        .pc_i        (pc                 ),
        .pc4_i       (pc4                ),
        .inst_i      (inst_i             ),  
        
        .pc_o        (if_id_pc           ),
        .have_inst_o (if_id_have_inst    ),
        .pc4_o       (if_id_pc4          ),
        .inst_o      (if_id_inst         )

    );

    // *********   ID    ****************

    CONTROLLER u_controller(
        .inst_i         (if_id_inst     ),
        .rst_n_i        (rst_n_i        ),

        .rf_we_o        (rf_we          ),
        .sext_op_o      (sext_op        ),
        .alu_op_o       (alu_op         ),

        .a_sel_o        (num_a_sel      ),
        .b_sel_o        (num_b_sel      ),
        .dram_we_o      (dram_we        ),
        .load_op_o      (load_op        ),
        .save_op_o      (save_op        ),
        .wb_sel_o       (rf_wd_sel      ),

        .is_load_o      (id_is_load     )


    );

    RF u_rf(
        .rst_n_i        (rst_n_i            ),
        .clk_i          (clk_i              ),
        .rR1_i          (rf_rR1             ),
        .rR2_i          (rf_rR2             ),
        .wR_i           (mem_wb_rf_wr       ),
        .wE_i           (mem_wb_rf_we       ),
        
        .wd_sel_i       (mem_wb_wb_sel      ),
        .dram_rd_i      (mem_wb_dram_rd     ),
        .alu_c_i        (mem_wb_alu_c       ),
        .npc_pc4_i      (mem_wb_pc4         ),
        .sext_ext_i     (mem_wb_imme        ),
        
        .rD1_o          (rf_rd1             ),
        .rD2_o          (rf_rd2             ),

        // trace
        .wD_o           (rf_wb_value        )
    );



    SEXT u_sext(
        .imme_i         (imme    ),
        .sext_op_i      (sext_op ),
        .imme_o         (imme_o  )
    );




    // ADR_ADDER u_adr_adder(
    //     .imme_i         (imme_o        ),
    //     .pc_i           (if_id_pc      ),
    //     .rf_rd1_i       (rf_rd1        ),
    //     .add_op_i       (adr_adder_op  ),
    //     .adr_o          (adr_adder_res )

    // );

    // *********   ID    ****************

    ID_EXE_REG u_id_exe_reg(
        .clk_i          (clk_i              ),
        .rst_n_i        (rst_n_i            ),
        .ctrl_flush_i   (id_exe_flush_ctrl  ),
        .data_flush_i   (id_exe_flush_data  ),
        // trace
        .pc_i           (if_id_pc           ),
        .have_inst_i    (if_id_have_inst    ),
        // control hz
        .inst_i         (if_id_inst         ),
        // rf
        .rf_we_i        (rf_we              ),
        .wb_sel_i       (rf_wd_sel          ),
        .pc4_i          (if_id_pc4          ),
        .rf_wr_i        (rf_wR              ),
        .rf_sr1_i       (rf_rR1             ),
        .rf_sr2_i       (rf_rR2             ),
        // alu
        .alu_a_sel_i    (num_a_sel          ),
        .alu_b_sel_i    (num_b_sel          ),
        .alu_op_i       (alu_op             ),
        .rf_rd1_i       (rf_rd1             ),
        .imme_i         (imme_o             ),
        // alu/dram
        .rf_rd2_i       (rf_rd2             ),
        // dram
        .dram_we_i      (dram_we            ),
        .load_op_i      (load_op            ),
        .save_op_i      (save_op            ),
        .is_load_i      (id_is_load         ),

        // trace
        .pc_o           (id_exe_pc            ),
        .have_inst_o    (id_exe_have_inst     ),
        // control hz
        .inst_o         (id_exe_inst          ),
        // rf
        .rf_we_o        (id_exe_rf_we         ),
        .wb_sel_o       (id_exe_wb_sel        ),
        .pc4_o          (id_exe_pc4           ),
        .rf_wr_o        (id_exe_rf_wr         ),
        .rf_sr1_o       (id_exe_rf_sr1        ),
        .rf_sr2_o       (id_exe_rf_sr2        ),
        // alu
        .alu_a_sel_o    (id_exe_alu_a_sel     ),
        .alu_b_sel_o    (id_exe_alu_b_sel     ),
        .alu_op_o       (id_exe_alu_op        ),
        .rf_rd1_o       (id_exe_rf_rd1        ),
        .imme_o         (id_exe_imme          ),
        // alu_dram
        .rf_rd2_o       (id_exe_rf_rd2        ),
        // dram
        .dram_we_o      (id_exe_dram_we       ),
        .load_op_o      (id_exe_load_op       ),
        .save_op_o      (id_exe_save_op       ),
        .is_load_o      (exe_is_load          )
    );

    // *********   EXE    ****************

    ALU  u_alu(
        .sr1_i          (rd1_hz            ),
        .sr2_i          (rd2_hz            ),
        .pc_i           (id_exe_pc         ),
        .imm_i          (id_exe_imme       ),
        .num_a_sel_i    (id_exe_alu_a_sel  ),
        .num_b_sel_i    (id_exe_alu_b_sel  ),
        .alu_op_i       (id_exe_alu_op     ),
        .alu_c_o        (alu_c             )
    );

    BRANCH  u_branch(
        .sr1_i          (rd1_hz     ),
        .sr2_i          (rd2_hz     ),
        .branch_un_i    (branch_un  ),
        .eq_o           (beq        ),
        .lt_o           (blt        )
    );

    
    CONTROL_HZ u_control_hz(
        .pc4_i          (id_exe_pc4     ),
        .alu_c_i        (alu_c          ),
        
        .inst_i         (id_exe_inst    ),        
        .eq_i           (beq            ),
        .lt_i           (blt            ),

        .bra_un_o       (branch_un          ),
        .pc_sel_o       (pc_sel_hz          ),
        .if_id_flush_o  (if_id_flush        ),
        .id_exe_flush_o (id_exe_flush_ctrl  )
    );



    DATA_HZ u_data_hz(
        // load use data hz
        .exe_is_load_i  (exe_is_load      ),
        .id_rf_sr1_i    (rf_rR1           ),
        .id_rf_sr2_i    (rf_rR2           ),
        .exe_rf_wr_i    (id_exe_rf_wr     ),
        
        // other data hz
        .exe_rf_rd1_i   (id_exe_rf_rd1    ),
        .exe_rf_rd2_i   (id_exe_rf_rd2    ),
        .exe_rf_sr1_i   (id_exe_rf_sr1    ),
        .exe_rf_sr2_i   (id_exe_rf_sr2    ),

        .mem_rf_we_i    (exe_mem_rf_we     ),
        .mem_wb_sel_i   (exe_mem_wb_sel    ),
        .mem_rf_wr_i    (exe_mem_rf_wr     ),        
        .mem_imme_i     (exe_mem_imme      ),
        .mem_alu_c_i    (exe_mem_alu_c     ),
        .mem_pc4_i      (exe_mem_pc4       ),

        .wb_rf_wr_i     (mem_wb_rf_wr      ),
        .wb_rf_we_i     (mem_wb_rf_we      ),
        .wb_wb_sel_i    (mem_wb_wb_sel     ),
        .wb_imme_i      (mem_wb_imme       ),
        .wb_alu_c_i     (mem_wb_alu_c      ),
        .wb_pc4_i       (mem_wb_pc4        ),
        .wb_dram_rd_i   (mem_wb_dram_rd    ),


        // load use data hz
        .pc_stall_o     (pc_stall         ),
        .if_id_stall_o  (if_id_stall      ),
        .id_exe_flush_o (id_exe_flush_data),

        // other data hz
        .exe_rd1_o      (rd1_hz           ),
        .exe_rd2_o      (rd2_hz           )
    );

    // *********   EXE    ****************
    
    EXE_MEM_REG u_exe_mem_reg(
        .clk_i           (clk_i             ),
        .rst_n_i         (rst_n_i           ),
        
        .pc_i            (id_exe_pc         ),
        .have_inst_i     (id_exe_have_inst  ),

        .load_op_i       (id_exe_load_op    ),
        .save_op_i       (id_exe_save_op    ),
        .dram_we_i       (id_exe_dram_we    ),
        .rf_rd2_i        (rd2_hz            ),
        .alu_c_i         (alu_c             ),

        .pc4_i           (id_exe_pc4        ),
        .imme_i          (id_exe_imme       ),
        .wb_sel_i        (id_exe_wb_sel     ),
        .rf_we_i         (id_exe_rf_we      ),
        .rf_wr_i         (id_exe_rf_wr      ),
        .is_load_i       (exe_is_load       ),       
        
        .pc_o            (exe_mem_pc        ),
        .have_inst_o     (exe_mem_hava_inst ),
        .load_op_o       (exe_mem_load_op   ),
        .save_op_o       (exe_mem_save_op   ),
        .dram_we_o       (exe_mem_dram_we   ),
        .rf_rd2_o        (exe_mem_rf_rd2    ),
        .alu_c_o         (exe_mem_alu_c     ),
        .pc4_o           (exe_mem_pc4       ),
        .imme_o          (exe_mem_imme      ),
        .wb_sel_o        (exe_mem_wb_sel    ),
        .rf_we_o         (exe_mem_rf_we     ),
        .rf_wr_o         (exe_mem_rf_wr     ),
        .is_load_o       (exe_mem_is_load   )
    );

    
    // *********   MEM    ****************
    
    // DRAM u_dram(
    //     .clk_i          (clk_i      ),
    //     .load_op_i      (load_op    ),
    //     .save_op_i      (save_op    ),
    //     .wdin_i         (rf_rd2     ),
    //     .adr_i          (alu_c      ),
    //     .dram_we_i      (dram_we    ),
    //     .rd_o           (dram_rd    )
    // );

    S_L_HZ u_s_l_hz(
        .wb_dram_we_i      (mem_wb_dram_we      ),
        .wb_dram_adr_i     (mem_wb_dram_adr     ),
        .wb_dram_wd_i      (mem_wb_dram_wd      ),

        .mem_is_load_i     (exe_mem_is_load     ),
        .mem_dram_adr_i    (exe_mem_alu_c[15:2] ),
        .mem_dram_rd_i     (sl_mem_rd_i         ),

        .mem_dram_rd_o     (sl_mem_rd_o         ) 
    );

    // *********   MEM    ****************

    MEM_WB_REG u_mem_wb_reg(
        .clk_i              (clk_i              ),
        .rst_n_i            (rst_n_i            ),

        .pc_i               (exe_mem_pc         ),
        .have_inst_i        (exe_mem_hava_inst  ),
        
        .pc4_i              (exe_mem_pc4        ),
        .imme_i             (exe_mem_imme       ),
        .alu_c_i            (exe_mem_alu_c      ),
        .dram_rd_i          (read_data_i        ),
        
        .wb_sel_i           (exe_mem_wb_sel     ),
        .rf_we_i            (exe_mem_rf_we      ),
        .rf_wr_i            (exe_mem_rf_wr      ),
        // s_l_hz
        .dram_we_i          (exe_mem_dram_we    ),
        .dram_adr_i         (exe_mem_alu_c[15:2]),
        .dram_wd_i          (sl_wb_wd_i         ),

        .pc_o               (mem_wb_pc          ),
        .have_inst_o        (mem_wb_have_inst   ),
        .pc4_o              (mem_wb_pc4         ),
        .imme_o             (mem_wb_imme        ),
        .alu_c_o            (mem_wb_alu_c       ),
        .dram_rd_o          (mem_wb_dram_rd     ),
        .wb_sel_o           (mem_wb_wb_sel      ),
        .rf_we_o            (mem_wb_rf_we       ),
        .rf_wr_o            (mem_wb_rf_wr       ),

        // s_L_hz
        .dram_we_o          (mem_wb_dram_we     ),
        .dram_adr_o         (mem_wb_dram_adr    ),
        .dram_wd_o          (mem_wb_dram_wd     )



    );

    // *********   WB    ****************





    // *********   WB    ****************

endmodule
