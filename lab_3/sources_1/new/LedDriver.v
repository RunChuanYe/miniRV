`timescale 1ns / 1ps


module LedDriver(
    input               clk_i,
    input               rst_i,
    input [7:0]         num1_i,
    input [7:0]         num2_i,
    input [2:0]         func_i,
    input [31:0]        led_wd_i,
    
    input [31:0]        led_addr_i,
    input               led_we_i,

    output reg [23:0]       led_o 
    );

    // assign led_o = {func_i, 5'b0, num1_i, num2_i};
    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i)
            led_o <= 23'b0;
        else if (led_addr_i == 32'hfffff060 && led_we_i)
            led_o <= led_wd_i[23:0];
        else 
            led_o <= led_o;
    end


endmodule
