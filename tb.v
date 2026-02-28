`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg rst_n;
    wire intr;    

    soc uut (
        .clk(clk),
        .rst_n(rst_n),
        .timer_interrupt(intr)
    );

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, testbench);

        // Init
        rst_n = 1;

        // Reset Pulse
        #100 rst_n = 0;
        #100 rst_n = 1; 

        #1000000000;
        $finish;
    end
endmodule
