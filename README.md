# ALU UVM Verification Environment

A UVM (Universal Verification Methodology) testbench built from scratch to verify a
32-bit Arithmetic Logic Unit (ALU) supporting addition, subtraction, and bitwise
AND / OR / XOR operations, with overflow/underflow and unsupported-opcode error
detection.

This project was built as a personal learning exercise in SystemVerilog/UVM-based
digital design verification. It follows the standard UVM component build order:
sequence item → sequencer → interface → driver/monitor → agent → sequences →
scoreboard → environment → test → top module → coverage subscriber.

## Project structure

```
design/     RTL of the DUT (alu.sv)
docs/       Verification plan 
verif/         UVM testbench components
sim/        Run scripts / filelists
labs/       Personal build log, written in my own words, one entry per component
```

## DUT overview

The ALU takes two 32-bit operands (`A`, `B`) and a 3-bit `Opcode`, and produces a
32-bit `Result` plus a 1-bit `Error` flag.

| Opcode | Operation |
|--------|-----------|
| 3'b000 | Addition |
| 3'b001 | Subtraction |
| 3'b010 | Bitwise AND |
| 3'b011 | Bitwise OR |
| 3'b100 | Bitwise XOR |
| 3'b101–111 | Reserved / unsupported (Error flag set) |

Full details are in [`docs/verification_plan.md`](docs/verification_plan.md).

## Status

🚧 Work in progress — components are being added incrementally as the testbench is built.

- [ ] Sequence item
- [ ] Sequencer
- [ ] Interface
- [ ] Driver
- [ ] Monitor
- [ ] Agent
- [ ] Sequences (directed + random)
- [ ] Scoreboard / reference model
- [ ] Environment
- [ ] Test
- [ ] Top TB module
- [ ] Coverage subscriber

## Bugs found

_(To be filled in once the scoreboard is running — this section will document any
mismatches found between the DUT and the reference model, with the stimulus that
triggered them.)_

## How to run

_(Fill in once `sim/` scripts are in place — e.g. simulator used, how to compile/run,
where to view waveforms/coverage.)_


