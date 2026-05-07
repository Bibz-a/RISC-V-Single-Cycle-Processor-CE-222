# 32-bit Single-Cycle RISC-V Processor (Verilog HDL)

## Overview
This project implements a functional **32-bit single-cycle RISC-V processor** using Verilog HDL. The processor is based on a subset of the RV32I instruction set and is designed for educational purposes to demonstrate core CPU architecture concepts such as datapath design, control signal generation, and instruction execution flow.

The architecture follows a **single-cycle design**, where each instruction is fetched, decoded, executed, and completed within one clock cycle.

---

## Features
- 32-bit RISC-V (RV32I subset) implementation
- Single-cycle datapath architecture
- Supports:
  - Arithmetic operations (add, sub)
  - Logical operations (and, or)
  - Immediate instructions (addi)
  - Memory operations (lw, sw)
  - Branching (beq)
- 32-register file (x0 hardwired to 0)
- ALU with multiple operation support
- Control unit generating all necessary control signals
- Separate instruction and data memory modules
- Fully verified using testbench and waveform analysis

---

## Architecture Overview
The processor consists of the following key components:

- Program Counter (PC)
- Instruction Memory
- Register File
- Arithmetic Logic Unit (ALU)
- Control Unit
- Data Memory
- Datapath with multiplexers and control logic

Each instruction conceptually passes through the following stages:

1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

Although these stages resemble a pipelined processor, they are executed within a **single clock cycle**, making the design dependent on the longest combinational path delay.

---

## Results and Verification
The processor was tested using a Verilog testbench. Simulation results confirm correct functionality:

- Arithmetic instructions execute correctly
- Memory read/write operations verified
- Branch instructions update PC accurately
- Register file updates validated
- Waveform analysis confirms correct datapath behavior

---

## Tools Used
- Verilog HDL
- Icarus Verilog (Simulation)
- GTKWave (Waveform Analysis)

---

## Reference
- Computer Organization and Design principles (RISC-V ISA)
- K. Henney, *Computer Organization and Architecture*

---

## Future Improvements
- Pipelined processor design (5-stage pipeline)
- Hazard detection and forwarding unit
- Expanded RV32M instruction support
- Cache memory integration
- Performance optimization

---

## Author
- Maimoona Saboor (Reg: 2024270)  
- Labiba Ahmad (Reg: 2024260)

---