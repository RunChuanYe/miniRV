`timescale 1ns / 1ps



module IROM(
    input  [31:0]   pc_i,
    output [31:0]   inst_o
    );

    // get inst from IROM
    prgrom U_prgrom_0 (
        .a      (pc_i[15:2]),
        .spo    (inst_o)
    );


endmodule
