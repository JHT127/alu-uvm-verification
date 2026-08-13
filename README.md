# ALU UVM Verification Environment

A UVM (Universal Verification Methodology) testbench built from scratch to
verify a 32-bit Arithmetic Logic Unit (ALU) supporting addition, subtraction,
bitwise AND/OR/XOR, and overflow/underflow/unsupported-opcode error
detection — built as a personal learning project during a VLSI Design
Verification internship.

## Table of Contents

- [Scope & Attribution](#scope--attribution)
- [Project Structure](#project-structure)
- [DUT Overview](#dut-overview)
- [Testbench Architecture](#testbench-architecture)
- [Build Log](#build-log)
- [Running the Regression](#running-the-regression)
- [Known Issues / Bugs Found](#known-issues--bugs-found)
- [Status](#status)
- [License](#license)

## Scope & Attribution

This repository contains **only my own work**: SystemVerilog/UVM code I
wrote, and a verification plan I authored myself. It does **not** contain
any internal training material, lab instruction documents, slide decks, or
proprietary documentation belonging to the organization where this project
was built as part of an internship. Any references to "labs" in this repo
(see `labs/`) are my own personal build notes, written in my own words to
document what I built and what I learned at each stage — not transcriptions
of any internal curriculum.

The DUT (`design/alu.sv`) is my own implementation, written to match a
generic ALU specification; it is not proprietary source code.

## Project Structure

```
design/       RTL of the DUT (alu.sv)
docs/         Verification plan
verif/        UVM testbench components
verif/tests/  Per-scenario UVM test classes
sim/          Makefile, file list, and simulation README
labs/         Personal build log, one entry per component, in my own words
```

## DUT Overview

The ALU takes two 32-bit operands (`A`, `B`) and a 3-bit `Opcode`, and
produces a 32-bit `Result` plus a 1-bit `Error` flag.

| Opcode | Operation |
|--------|-----------|
| 3'b000 | Addition |
| 3'b001 | Subtraction |
| 3'b010 | Bitwise AND |
| 3'b011 | Bitwise OR |
| 3'b100 | Bitwise XOR |
| 3'b101–111 | Reserved / unsupported (`Error` flag set) |

`Error` is also expected on signed addition overflow or subtraction
underflow. Full details are in [`docs/verification_plan.md`](docs/verification_plan.md).

## Testbench Architecture

Standard UVM component hierarchy, built incrementally:

```
sequence  →  sequencer  →  driver  ──┐
                                      ├──▶  DUT
                            monitor ◀─┘
                               │
                               ├──▶ scoreboard  (checks correctness)
                               └──▶ subscriber  (samples coverage)
```

| Component | File |
|---|---|
| Sequence Item | `verif/alu_sequence_item.sv` |
| Sequencer | `verif/alu_sequencer.sv` |
| Interface | `verif/alu_interface.sv` |
| Driver | `verif/alu_driver.sv` |
| Monitor | `verif/alu_monitor.sv` |
| Agent | `verif/alu_agent.sv` |
| Sequences | `verif/alu_sequences/` |
| Scoreboard | `verif/alu_scoreboard.sv` |
| Subscriber (coverage) | `verif/alu_subscriber.sv` |
| Environment | `verif/alu_environment.sv` |
| Package | `verif/alu_pkg.sv` |
| Tests | `verif/alu_random_test.sv`, `verif/alu_regression_test.sv`, `verif/tests/` |
| TB Top | `verif/alu_tb_top.sv` |

## Build Log

Each component was built and documented incrementally — see
[`labs/`](labs/) for a written account of what was built and what I learned
at each stage, from the sequence item and sequencer through to the
coverage subscriber.

## Running the Regression

Simulated on Cadence Xcelium. See [`sim/README.md`](sim/README.md) for full
details. Quick start (from `sim/`):

```bash
make summary     # runs every registered test, prints PASS/FAIL per test
make waves       # opens the captured waveform in SimVision
```

## Known Issues / Bugs Found

Directed testing surfaced mismatches between the DUT and the independently
written reference model, concentrated in overflow/underflow detection and
in how the `Error` flag persists across cycles. See
[`docs/verification_plan.md`](docs/verification_plan.md) Section 10 for the
full writeup once regression data is finalized.

## Status

- [x] Sequence item
- [x] Sequencer
- [x] Interface
- [x] Driver
- [x] Monitor
- [x] Agent
- [x] Sequences (directed + random)
- [x] Scoreboard / reference model
- [x] Environment
- [x] Test classes (bundled + per-scenario)
- [x] Top TB module
- [x] Coverage subscriber
- [ ] Finalized coverage report
- [ ] Finalized bug writeup with full regression results

