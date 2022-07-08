`timescale 1ns / 1ps


module top_computer_sim(

    );

    reg clk;
    reg rst;

    top_computer u_top_computer(
        .clk       (clk   ),
        .rst_n       (rst )
    );

    always #1 clk = ~clk;

    initial begin
        #0          clk = 0;
                    rst = 0;
        #50         rst = 1;
        #50        rst = 0;
    end




endmodule
