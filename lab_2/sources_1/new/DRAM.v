`include "param.v"
`timescale 1ns / 1ps


module DRAM(

    input  [2 :0]   load_op_i   ,
    input  [1 :0]   save_op_i   ,
    input  [31:0]   wdin_i      ,
    input  [31:0]   rd_i        ,

    input  [ 1:0]   adr_i       ,
    output [31:0]   wdin_o      ,
    output [31:0]   rd_o    
    );

    /*
        read part
    */ 

    reg [ 7:0]  lb_tmp;
    reg [15:0]  lh_tmp;
    // lb/lbu
    always @(*) begin
        case (adr_i)
            2'b00:  
                lb_tmp = rd_i[ 7:0];
            2'b01:
                lb_tmp = rd_i[15:8];
            2'b10:
                lb_tmp = rd_i[23:16];
            2'b11:
                lb_tmp = rd_i[31:24]; 
            default: 
                lb_tmp = 8'b0;
        endcase
    end
    
    // lh/lhu
    always @(*) begin
        case (adr_i)
            2'b00:
                lh_tmp = rd_i[15:0 ];
            2'b10:
                lh_tmp = rd_i[31:16];
            default: 
                lh_tmp = 16'b0;
        endcase
    end

    // sign extent
    // load byte
    wire [31:0] load_b;
    // load byte unsigned
    wire [31:0] load_bu;
    // load half word (two byte)
    wire [31:0] load_h;
    // load half word unsigned (two byte)
    wire [31:0] load_hu;

    assign load_b = {{24{lb_tmp[7]}}, lb_tmp[7:0]};
    assign load_bu = {24'b0, lb_tmp[7:0]};
    assign load_h = {{16{lh_tmp[15]}}, lh_tmp[15:0]};
    assign load_hu = {16'b0, lh_tmp[15:0]};


    // get the output data
    reg [31:0] output_tmp;
    assign rd_o = output_tmp;

    always @(*) begin
        case (load_op_i)
        `LOADB :           output_tmp = load_b;
        `LOADBU:           output_tmp = load_bu;
        `LOADH :           output_tmp = load_h;
        `LOADHU:           output_tmp = load_hu; 
        default:           output_tmp = rd_i;
        endcase
    end



    /*
        write part 
    */ 

    reg [31:0] wdin_tmp;

    assign wdin_o = wdin_tmp;

    reg [31:0]  sb_tmp;
    reg [31:0]  sh_tmp;

    always @(*) begin
        case (adr_i)
            2'b00:
                sb_tmp = {rd_i[31:8], wdin_i[7:0]};
            2'b01:
                sb_tmp = {rd_i[31:16], wdin_i[7:0], rd_i[7:0]};
            2'b10:
                sb_tmp = {rd_i[31:24], wdin_i[7:0], rd_i[15:0]};
            2'b11:
                sb_tmp = {wdin_i[7:0], rd_i[23:0]}; 
            default: 
                sb_tmp = 32'b0;
        endcase
    end

    always @(*) begin
        case (adr_i)
            2'b00:
                sh_tmp = {rd_i[31:16], wdin_i[15:0]};
            2'b10:
                sh_tmp = {wdin_i[15:0], rd_i[15:0]}; 
            default: 
                sh_tmp = 32'b0;
        endcase
    end

    always @(*) begin
        case (save_op_i)
            `SAVEB:
                wdin_tmp = sb_tmp;
            `SAVEH:
                wdin_tmp = sh_tmp;
            `SAVEW:
                wdin_tmp = wdin_i; 
            default: 
                wdin_tmp = wdin_i;
        endcase    
        
    end


endmodule
