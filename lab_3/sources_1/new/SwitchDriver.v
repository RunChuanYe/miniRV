`timescale 1ns / 1ps


module SwitchDriver(
    input           rst_n_i,
    input [7:0]     num1_i,
    input [7:0]     num2_i,
    input [2:0]     func_i,
    
    // input [31:0]    sw_wd_i,
    // input [31:0]    sw_adr_i,
    // input           sw_we_i,
    output reg [31:0]    sw_rd_o
    );

    always @(*) begin
        // if (rst_n_i)
        //     sw_rd_o = 32'b0;
        // else
            sw_rd_o = {8'b0, func_i, 5'b0, num1_i, num2_i};
    end


endmodule
