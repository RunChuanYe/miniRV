`timescale 1ns / 1ps


module miniRV(
    // 100MHz clk from board
    input   clk_i                   ,        
    // reset signal from board
    input   rst_n_i                 ,

    output [31:0]   pc_o            ,
    input  [31:0]   inst_i          ,
    
    output [31:0]   adr_o           ,
    output          we_o            ,
    output [31:0]   write_data_o    ,

    output [ 2:0]   load_op_o       ,
    output [ 1:0]   save_op_o       ,
    
    input  [31:0]   read_data_i     ,

    output [4:0]    reg_trace       ,
    output [31:0]   wb_value        ,
    output          rf_we_o 
    );

    wire [31:0]     pc;
    wire [31:0]     pc4 = pc + 4;
    wire            pc_sel;
    wire            pc_en;
    
    wire [31:0]     alu_c;
   
    wire [31:0]     inst;
    wire [4:0]      rf_rR1 = inst[19:15];
    wire [4:0]      rf_rR2 = inst[24:20];
    wire [4:0]      rf_wR  = inst[11:7 ];
    wire            rf_we;
    wire [1:0]      rf_wd_sel;
    wire [31:0]     dram_rd;
    wire [31:0]     rf_rd1;
    wire [31:0]     rf_rd2;

    wire [31:7]     imme = inst[31:7];
    wire [2:0]      sext_op;
    wire [31:0]     imme_o;

    wire            num_a_sel;
    wire            num_b_sel;
    wire [3:0]      alu_op;
    
    wire            branch_un;
    wire            beq;
    wire            blt;

    wire [ 2:0]     load_op;
    wire [ 1:0]     save_op;
    wire            dram_we;

    assign          pc_o = pc;
    // device adr
    assign          adr_o = alu_c;
    // device write enable
    assign          we_o = dram_we;
    // write data
    assign          write_data_o = rf_rd2;
    // read data
    assign          dram_rd = read_data_i;
    // inst
    assign          inst = inst_i;
    // load op
    assign          load_op_o = load_op;
    // save op
    assign          save_op_o = save_op; 


    // for trace
    assign rf_we_o = rf_we;
    assign reg_trace = rf_wR;


    PC u_pc(
        .clk_i      (clk_i      ),
        .rst_n_i    (rst_n_i    ),
        
        .pc4_i      (pc4        ),
        .alu_c_i    (alu_c      ),
        .pc_sel_i   (pc_sel     ),
        .en_i       (pc_en      ),

        .pc_o       (pc         )
    );

    RF u_rf(
        .rst_n_i        (rst_n_i    ),
        .clk_i          (clk_i      ),
        .rR1_i          (rf_rR1     ),
        .rR2_i          (rf_rR2     ),
        .wR_i           (rf_wR      ),
        .wE_i           (rf_we      ),
        
        .wd_sel_i       (rf_wd_sel  ),
        .dram_rd_i      (dram_rd    ),
        .alu_c_i        (alu_c      ),
        .npc_pc4_i      (pc4        ),
        .sext_ext_i     (imme_o     ),
        
        .rD1_o          (rf_rd1     ),
        .rD2_o          (rf_rd2     ),

        // trace
        .wD_o           (wb_value   )
    );



    SEXT u_sext(
        .imme_i         (imme    ),
        .sext_op_i      (sext_op ),
        .imme_o         (imme_o  )
    );

    ALU  u_alu(
        .sr1_i          (rf_rd1     ),
        .sr2_i          (rf_rd2     ),
        .pc_i           (pc         ),
        .imm_i          (imme_o     ),
        .num_a_sel_i    (num_a_sel  ),
        .num_b_sel_i    (num_b_sel  ),
        .alu_op_i       (alu_op     ),
        .alu_c_o        (alu_c      )
    );


    BRANCH  u_branch(
        .sr1_i          (rf_rd1     ),
        .sr2_i          (rf_rd2     ),
        .branch_un_i    (branch_un  ),
        .eq_o           (beq        ),
        .lt_o           (blt        )
    );

    // DRAM u_dram(
    //     .clk_i          (clk_i      ),
    //     .load_op_i      (load_op    ),
    //     .save_op_i      (save_op    ),
    //     .wdin_i         (rf_rd2     ),
    //     .adr_i          (alu_c      ),
    //     .dram_we_i      (dram_we    ),
    //     .rd_o           (dram_rd    )
    // );

    CONTROLLER u_controller(
        .inst_i         (inst       ),
        .eq_i           (beq        ),
        .lt_i           (blt        ),
        
        .pc_sel_o       (pc_sel     ),
        .pc_en_o        (pc_en      ),
        .rf_we_o        (rf_we      ),
        .sext_op_o      (sext_op    ),
        .alu_op_o       (alu_op     ),

        .a_sel_o        (num_a_sel  ),
        .b_sel_o        (num_b_sel  ),
        .bra_un_o       (branch_un  ),
        .dram_we_o      (dram_we    ),
        .load_op_o      (load_op    ),
        .save_op_o      (save_op    ),
        .wb_sel_o       (rf_wd_sel  )
    );


endmodule






