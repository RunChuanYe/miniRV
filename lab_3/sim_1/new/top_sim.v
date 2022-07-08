`timescale 1ns / 1ps


module top_sim(

    );

    reg clk;
    reg rst_n;

    top u_top(
        .clk     (clk   ),
        .rst_n   (rst_n )
    );

    always #1 clk = ~clk;

    initial begin
        #0          clk = 0;
                    rst_n = 0;
        #50         rst_n = 1;
    end



endmodule
