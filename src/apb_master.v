`timescale 1ns / 1ps

module apb_master #(
    parameter APB_BASE_ADDR = 32'h4000_0000, // Base address for peripherals
    parameter APB_ADDR_MASK = 32'hFFFF_0000  // Mask to detect peripheral space 
)(
    input             clk,
    input             rst,
    
    // Interface to RISC-V Core
    input      [31:0] rv_addr,       // Connect to DataAddr
    input      [31:0] rv_wdata,      // Connect to WriteData
    input             rv_mem_write,  // Connect to MemWrite
    input             rv_mem_read,   // Connect to (ResultSrc == 2'b01)
    output reg [31:0] rv_rdata,      // Connect to Result Mux 
    output reg        cpu_stall,     // Connect to Pipeline Stall
    
    // Interface to APB Slaves
    output reg        PSEL,
    output reg        PENABLE,
    output reg        PWRITE,
    output reg [31:0] PADDR,
    output reg [31:0] PWDATA,
    input      [31:0] PRDATA,
    input             PREADY       
);

    // State Machine
    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ACCESS = 2'b10;

    reg [1:0] state;
    
    // Address Decoding: Check if address matches APB address space
    wire is_peripheral = ((rv_addr & APB_ADDR_MASK) == (APB_BASE_ADDR & APB_ADDR_MASK)) && (rv_mem_write || rv_mem_read);

    // Stall Logic
    always @(*) begin
        if (is_peripheral) begin
            if (state == ACCESS && PREADY) begin
                cpu_stall = 1'b0; // Release stall
            end else begin
                cpu_stall = 1'b1; // Stall CPU
            end
        end else begin
            cpu_stall = 1'b0;
        end
    end

    // Data Read Logic
    always @(*) begin
        if (state == ACCESS && PREADY && !PWRITE) begin
            rv_rdata = PRDATA;
        end else begin
            rv_rdata = 32'b0; 
        end
    end

    // APB State Machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            PSEL      <= 0;
            PENABLE   <= 0;
            PWRITE    <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (is_peripheral) begin
                        // Capture Request
                        PSEL      <= 1;
                        PWRITE    <= rv_mem_write;
                        PADDR     <= rv_addr;
                        PWDATA    <= rv_wdata;
                        state     <= SETUP;
                    end else begin
                        PSEL      <= 0;
                        PENABLE   <= 0;
                    end
                end

                SETUP: begin
                    // APB Protocol: Assert Enable
                    PENABLE <= 1;
                    state   <= ACCESS;
                end

                ACCESS: begin
                    if (PREADY) begin
                        // Transaction Complete
                        PENABLE   <= 0;
                        PSEL      <= 0;
                        state     <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule