`include "param.v"
`timescale 1ns / 1ps

module BUS(
    // cpu - bus
    // input  [2 :0]   load_op_i   ,
    // input  [1 :0]   save_op_i   ,
    input  [31:0]   wd_i        ,
    input  [31:0]   adr_i       ,
    input           we_i        ,
    output [31:0]   rd_o        ,

    // bus - dram
    output [31:0]   mem_addr_o  ,
    output [31:0]   mem_wd_o    ,
    output          mem_we_o    ,

    input  [31:0]   mem_rd_i    ,

    // bus - other device
    output [31:0]   io_addr_o   ,
    output [31:0]   io_wd_o     ,
    output          io_we_o     ,
    input  [31:0]   io_rd_i  
    );


    /*
        MEM PART
    */  

    // is mem addr ?
    assign is_mem_addr = (adr_i[31:12] != 20'hfffff);
    
    // adr 
    assign mem_addr_o = is_mem_addr ? adr_i : 32'b0;
    
    // we
    assign mem_we_o = is_mem_addr ? we_i : 1'b0;

    // wd
    assign mem_wd_o = is_mem_addr ? wd_i : 32'b0;

    /*
        IO PART
    */ 

    // is io addr ? 
    assign is_io_addr = (adr_i[31:12] == 20'hfffff);
    
    // adr 
    assign io_addr_o = is_io_addr ? adr_i : 32'b0;

    // we
    assign io_we_o = is_io_addr ? we_i : 1'b0;

    // wd
    assign io_wd_o = is_io_addr ? wd_i : 32'b0;

    
    /*
        OUTPUT DATA
    */ 
    assign rd_o = is_io_addr ? io_rd_i : mem_rd_i;


endmodule
