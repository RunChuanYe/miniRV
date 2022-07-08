`include "param.v"
`timescale 1ns / 1ps


module top_computer(
    input             clk         ,
    input             rst         ,
	input  wire       button      ,
	
    // Switch Driver
    input  wire [2:0] func        ,
	input  wire [7:0] num1        ,
	input  wire [7:0] num2        ,
    // Digit Driver
 	output wire [7:0] led_en      ,
	output wire       led_ca      ,
	output wire       led_cb      ,
    output wire       led_cc      ,
	output wire       led_cd      ,
	output wire       led_ce      ,
	output wire       led_cf      ,
	output wire       led_cg      ,
	output wire       led_dp      ,

    output   [23:0]   led
    );

    // rst_n
    wire rst_n = ~rst;

    // IROM -CPU
    wire [31:0] pc;
    wire [31:0] inst;

    // CPU - DRAM
    wire [ 2:0] load_op;
    wire [ 1:0] save_op;

    // CPU - BUS
    wire [31:0] adr       ;
    wire [31:0] read_data ;
    wire [31:0] write_data;
    wire        we        ;


    // BUS - MEM
    wire [31:0] mem_wd_i;
    wire [31:0] mem_wd_o;
    wire [31:0] mem_addr;
    wire [31:0] mem_rd_i;
    wire [31:0] mem_rd_o;
    wire        mem_we;

    wire [31:0] sl_mem_rd_i;

    // BUS - IO
    wire [31:0] io_rd;
    wire [31:0] io_wd;
    wire [31:0] io_addr;
    wire        io_we;

    // clk cpu
    wire        clk_g;
    wire        locked;
    wire        clk_digit;
    
    // cpu clk
    cpuclk u_cpuclk(
        .clk_in1    (clk        ),
        .clk_out1   (clk_g      ),
        .locked     (locked     )

    );

    // digit clk
    divider u_divider(
        .clk_i      (clk        ),
        .rst_n      (rst_n      ),
        .clk_o      (clk_digit  )
    );



    // IROM
    IROM u_irom(
        .pc_i       (pc     ),
        .inst_o     (inst   )
    );

    // CPU
    miniRV u_miniRV(
        .clk_i          (clk_g      ),
        .rst_n_i        (rst_n      ),
        // IROM
        .pc_o           (pc         ),
        .inst_i         (inst       ),
        // BUS
        .adr_o          (adr        ),
        .we_o           (we         ),
        .write_data_o   (write_data ),
        
        .load_op_o      (load_op    ),
        .save_op_o      (save_op    ),

        .read_data_i    (read_data  ),

        // s_l_hz
        .sl_wb_wd_i     (mem_wd_o   ),
        .sl_mem_rd_i    (mem_rd_i   ),
        .sl_mem_rd_o    (sl_mem_rd_i)
    );

    // BUS
    BUS u_bus(
        // cpu - bus
        // .load_op_i      (load_op    ),
        // .save_op_i      (save_op    ),
        
        .wd_i           (write_data ),
        .adr_i          (adr        ),
        .we_i           (we         ),
        .rd_o           (read_data  ),
        
        // bus - mem 
        .mem_addr_o     (mem_addr   ),
        .mem_wd_o       (mem_wd_i   ),
        .mem_rd_i       (mem_rd_o   ),
        .mem_we_o       (mem_we     ),

        // bus - io
        .io_addr_o      (io_addr    ),
        .io_wd_o        (io_wd      ),
        .io_rd_i        (io_rd      ),
        .io_we_o        (io_we      )
    );

    // // DRAM
    // DRAM u_dram(
    //     .clk_i          (clk_g      ),
        
    //     .load_op_i      (load_op    ),
    //     .save_op_i      (save_op    ),

    //     .wdin_i         (mem_wd     ),
    //     .adr_i          (mem_addr   ),
    //     .rd_o           (mem_rd     ),
    //     .dram_we_i      (mem_we     )
    // );

    DRAM u_dram_1(
        .load_op_i      (load_op        ),
        .save_op_i      (save_op        ),
        .rd_i           (sl_mem_rd_i    ),
        .rd_o           (mem_rd_o       ),
        .adr_i          (mem_addr[1:0]  ),
        .wdin_i         (mem_wd_i       ),
        .wdin_o         (mem_wd_o       )  
    );

    dram u_dram(
        .clk    (clk_g       ),
        // address
        .a      (mem_addr[15:2]),
        // data out
        .spo    (mem_rd_i  ),
        // write enable
        .we     (mem_we    ),
        // data in
        .d      (mem_wd_o  )
    );


    // DigitDriver
    DigitDriver u_digitDriver(
        .clk            (clk_digit  ),
        .clk_g          (clk_g      ),
        .rst_n          (rst_n      ),
        .button         (button     ),
        .led_ca		    (led_ca	    ),
        .led_cc		    (led_cc	    ),
        .led_cb		    (led_cb	    ),
        .led_cd		    (led_cd	    ),
        .led_ce		    (led_ce	    ),
        .led_cf		    (led_cf	    ),
        .led_cg		    (led_cg	    ),
        .led_dp		    (led_dp	    ),
        .led_en		    (led_en	    ),
        
        // bug - digitDriver
        .digit_adr_i    (io_addr    ),
        .digit_wd_i     (io_wd      ),
        .digit_we_i     (io_we      )
    );

    // SwitchDriver
    SwitchDriver u_switchDriver(
        .rst_n_i        (rst_n      ),
        // top - switch
        .num1_i         (num1       ),
        .num2_i         (num2       ),
        .func_i         (func       ),
        // bus - switch
        .sw_rd_o        (io_rd      )
    );


    // ledDriver
    LedDriver u_ledDriver(
        .clk_i          (clk_g      ),
        .rst_i          (rst_n      ),
        .num1_i         (num1       ),
        .num2_i         (num2       ),
        .func_i         (func       ),
        .led_o          (led        ),
        .led_wd_i       (io_wd      ),
        
        .led_addr_i     (io_addr    ),
        .led_we_i       (io_we      )
    );



endmodule
