`timescale 1ns / 1ps

module core_tb;

    reg clk;
    reg rst;

    wire        MemWrite;
    wire [31:0] WriteData, DataAdr, ReadData;
    wire [2:0]  funct3;
    wire [1:0]  ResultSrcOut;

    RiscV core (
        .clk(clk),
        .rst(rst),
        .Ext_MemWrite(1'b0),
        .Ext_WriteData(32'b0),
        .Ext_DataAdr(32'b0),
        .MemWrite(MemWrite),
        .WriteData(WriteData),
        .DataAdr(DataAdr),
        .Stall(1'b0),          
        .ReadData(ReadData),
        .ResultSrcOut(ResultSrcOut),
        .funct3(funct3)
    );

    data_mem dmem (
        .clk(clk),
        .WE(MemWrite),
        .funct3(funct3),
        .A(DataAdr),
        .WD(WriteData),
        .RD(ReadData)
    );

    always #5 clk = ~clk; 

    initial begin
        $dumpfile("core_waveform.vcd");
        $dumpvars(0, core_tb);

        clk = 0; rst = 1;
        #25 rst = 0;

        // Failsafe timeout
        #1500;
        $display("Testbench Timeout!");
        $finish;
    end

    always @(posedge clk) begin
        if (!rst) begin
            
            if (MemWrite) begin
                $display("[%0t] S-Type Executed: Memory Write -> Addr: 0x%h | Data: %0d", $time, DataAdr, WriteData);
            end
            
            if (core.pc == 32'h00000040) begin
                $display("\n[%0t] *** ALL TESTS PASSED! ***", $time);
                #20;
                $finish;
            end
            else if (core.pc == 32'h00000034) begin
                $display("\n[%0t] *** TEST FAILED! *** (Trapped in Branch BEQ)", $time);
                #20;
                $finish;
            end
            else if (core.pc == 32'h0000003C) begin
                $display("\n[%0t] *** TEST FAILED! *** (Trapped in Jump/Link)", $time);
                #20;
                $finish;
            end
        end
    end

endmodule