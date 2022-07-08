`timescale 1ns / 1ps


module top_sim(

    );

    reg clk;
    reg rst_n;

    top u_top(
        .clk_i   (clk   ),
        .rst_n_i (rst_n )
    );

    always #1 clk = ~clk;

    initial begin
        #0          clk = 0;
                    rst_n = 0;
        #500        rst_n = 1;
    end



endmodule
