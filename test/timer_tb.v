`timescale 1ns / 1ps

module timer_tb;
    reg clk;
    reg rst_n;
    wire timer_interrupt;

    soc uut (
        .clk(clk),
        .rst_n(rst_n),
        .timer_interrupt(timer_interrupt)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("timer_waveform.vcd");
        $dumpvars(0, timer_tb);

        clk = 0; rst_n = 0;
        #100 rst_n = 1; 

        // Fail-safe Timeout
        #5000;
        $display("\n[%0t] Timeout! The interrupt never fired.", $time);
        $finish;
    end

    always @(posedge clk) begin
        if (rst_n && uut.bridge.PSEL && uut.bridge.PENABLE && uut.bridge.PWRITE) begin
            $display("[%0t] APB WRITE -> Addr: 0x%08x | Data: %0d", $time, uut.bridge.PADDR, uut.bridge.PWDATA);
        end
    end

    always @(posedge timer_interrupt) begin
        $display("\n[%0t] *** Test Passed: Interrupt Detected! ***", $time);
        #100; 
        $finish;
    end

endmodule