# Custom RISC-V SoC with APB Peripherals

A custom 32-bit RISC-V System-on-Chip (SoC) designed from scratch in Verilog. This project features a RISC-V processor core, an Advanced Peripheral Bus (APB) bridge, and a memory-mapped hardware system timer capable of generating interrupts.

> **🚧 WORK IN PROGRESS 🚧**
>
> Please note that this project is currently under development. While the core processing unit and the APB timer peripheral are fully functional, the SoC is not yet complete.
>
> **Upcoming Features to be added:**
> * **PWM (Pulse Width Modulation) Controller**
> * **UART (Universal Asynchronous Receiver-Transmitter)**
> * **SPI (Serial Peripheral Interface)**
> 
> and more...

## Architecture Overview

* **RISC-V Core:** A custom 32-bit processor implementing the base integer instruction set (RV32I). It features independent Fetch, Decode, and Execute modules.
* **Memory Map:**
  * `0x0000_0000` to `0x3FFF_FFFF`: Data RAM.
  * `0x4000_0000` to `0x4000_000C`: Memory-mapped APB Peripherals (System Timer).


* **APB Bridge:** Handles memory stalls, decoding, and bus transactions between the fast CPU and slower memory-mapped peripherals.
* **System Timer:** A configurable countdown timer with a prescaler, supporting One-Shot and Periodic modes, and overrun detection. It drives a hardware interrupt wire back to the SoC level.

## How to Run the Simulations

This project is tested using raw machine code instructions loaded into the instruction memory (`instr.mem`). No C-compiler toolchain is currently used to run these specific tests.

### Prerequisites

You will need an HDL simulator to compile and run the Verilog code. I use **Icarus Verilog (`iverilog`)**.

* [Download Icarus Verilog](https://steveicarus.github.io/iverilog/)

### Test 1: RISC-V Core Verification

This test isolates the RISC-V core and runs it through a sequence of ALU, Branch, Memory, and Jump instructions to ensure the datapath is correct.

1. Navigate to the `test/` directory:
```bash
cd test
```


2. Open `instr.mem` and replace its contents with the hex codes found at the bottom of `core_test_instr.txt`.
3. Compile the simulation:
```bash
iverilog -o core core_tb.v ../src/*.v

```


4. Run the simulation:
```bash
vvp core

```


*Expected Output: You should see data memory writes in the console, ending with `*** ALL TESTS PASSED! ***`.*

### Test 2: SoC, APB Bridge, and Timer Interrupt Verification

This test runs the entire SoC. The CPU will configure the APB Timer via memory-mapped addresses, start the timer, and enter an infinite loop. The hardware timer will count down and physically assert the interrupt pin.

1. Navigate to the `test/` directory (if not already there):
```bash
cd test

```


2. Open `instr.mem` and replace its contents with the hex codes found at the bottom of `timer_test_instr.txt`.
3. Compile the simulation:
```bash
iverilog -o timer timer_tb.v ../src/*.v

```


4. Run the simulation:
```bash
vvp timer

```


*Expected Output: You will see the CPU performing APB Writes to setup the timer, followed shortly by `*** Test Passed: Interrupt Detected! ***` when the hardware timer hits zero.*

### 📊 Viewing Waveforms

Both testbenches automatically generate `.vcd` files (`core_waveform.vcd` and `timer_waveform.vcd`). You can open these files using [GTKWave](https://gtkwave.sourceforge.net/) to inspect the clock cycles, APB bus transactions, and CPU registers.
