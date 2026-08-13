# ALU Verification Plan

## 1. Introduction

### Purpose

This document describes the verification plan for a 32-bit Arithmetic
Logic Unit (ALU), covering the design's intended behavior, the strategy
used to verify it, the UVM testbench architecture built to execute that
strategy, and the results obtained from running it.

### Scope

Verification is scoped to top-level, black-box verification of the ALU
module. The DUT is exercised exclusively through its external interface
(`A`, `B`, `Opcode`, `Result`, `Error`, `clk`, `rst`) — internal signals are
not probed or driven directly. This keeps the testbench portable and
focused on validating that the ALU's observable behavior matches its
specification, regardless of internal implementation.

### Assumptions and Constraints

**Assumptions:**
- The design is stable but not intended to be synthesizable in this form.
- Verification uses the UVM methodology throughout.
- Functional coverage goals are achievable and measurable via SystemVerilog
  covergroups.
- Clock and reset are supplied correctly by the testbench top module.

**Constraints:**
- None identified at this stage.

## 2. Design Overview

### Functional Summary

The ALU accepts two 32-bit operands (`A`, `B`) and a 3-bit `Opcode`, and
produces a 32-bit `Result` along with a 1-bit `Error` flag.

| Opcode | Operation |
|---|---|
| `3'b000` | Addition |
| `3'b001` | Subtraction (`A - B`, via two's complement addition) |
| `3'b010` | Bitwise AND |
| `3'b011` | Bitwise OR |
| `3'b100` | Bitwise XOR |
| `3'b101` – `3'b111` | Reserved / unsupported — `Error` is set |

`Error` is also expected to be set when addition overflows or subtraction
underflows a signed 32-bit result.

### Interface

| Signal | Width | Direction | Description |
|---|---|---|---|
| `clk` | 1 | input | Clock signal to the module |
| `rst` | 1 | input | Synchronous reset of internal state |
| `A` | 32 | input | First operand (signed) |
| `B` | 32 | input | Second operand |
| `Opcode` | 3 | input | Selects the operation to perform |
| `Result` | 32 | output | Result of the selected operation |
| `Error` | 1 | output | Set on overflow/underflow or unsupported opcode |

## 3. Verification Strategy

### Methodology

The environment is built using UVM. Stimulus generation, driving, and
monitoring follow the standard UVM component split (sequence item,
sequencer, driver, monitor, agent), and checking is performed by a
scoreboard containing an independently written reference model — not a
copy of the DUT's own logic — so that a bug present in the DUT has no
chance of also being present in the model checking it.

### Test Selection

Tests are organized around each ALU operation plus dedicated error-handling
and corner-case scenarios:

1. **Addition** — random positive/negative operand combinations, plus a
   directed overflow case (`32'h7FFFFFFF + 1`).
2. **Subtraction** — random positive/negative operand combinations, plus a
   directed underflow case (`32'h80000000 - 1`).
3. **Bitwise AND / OR / XOR** — random operand combinations per opcode,
   exercising general bit patterns.
4. **Unsupported opcode handling** — `Opcode` constrained to the three
   reserved values (`3'b101`, `3'b110`, `3'b111`), verifying `Error` is set.
5. **Randomized stress testing** — fully unconstrained `A`/`B`/`Opcode`
   combinations run repeatedly (500 iterations in the random regression
   test) to surface unexpected interactions.

### Specific Corner Cases Targeted

- Maximum positive integer (`32'h7FFFFFFF`) and minimum negative integer
  (`32'h80000000`) as operands.
- Alternating bit patterns (`32'hAAAAAAAA`, `32'h55555555`) and full
  saturation (`32'hFFFFFFFF`, `32'h00000000`) for bitwise operations.
- Zero and one as an operand paired with a non-zero value.
- Sign-bit-toggling additions/subtractions.
- All three reserved opcode values.

## 4. Testbench Architecture

Built incrementally, following the standard UVM component hierarchy:

| Component | Responsibility |
|---|---|
| **Sequence Item** (`alu_sequence_item`) | Transaction class carrying both DUT inputs (`rst`, `A`, `B`, `Opcode`) and outputs (`Result`, `Error`) |
| **Sequencer** (`alu_sequencer`) | Delivers sequence items to the driver in order |
| **Interface** (`alu_interface`) | Bundles DUT signals; provides a negedge-clocked driver clocking block and a posedge-clocked monitor clocking block, each restricted via a dedicated modport |
| **Driver** (`alu_driver`) | Drives sequence item fields (including `rst`) onto the DUT via the interface's driver clocking block |
| **Monitor** (`alu_monitor`) | Samples DUT inputs and outputs via the interface's monitor clocking block and broadcasts observed transactions |
| **Agent** (`alu_agent`) | Bundles sequencer, driver, and monitor; active/passive configurable |
| **Sequences** (`verif/alu_sequences/`) | One sequence per operation, plus random, unsupported-opcode, overflow, and underflow sequences |
| **Scoreboard** (`alu_scoreboard`) | Receives monitored transactions, computes expected results via an independent reference model, and compares against the DUT's actual output |
| **Subscriber** (`alu_subscriber`) | Receives the same monitored transactions and samples functional coverage on `A`, `B`, `Opcode`, `Result`, and `Error` |
| **Environment** (`alu_environment`) | Instantiates the agent, scoreboard, and subscriber; fans the monitor's output out to both |
| **Tests** (`alu_random_test`, `alu_regression_test`) | Configure the environment and start sequences on the sequencer |
| **TB Top** (`alu_tb_top`) | Plain SystemVerilog module: generates clock, instantiates interface and DUT, publishes the virtual interface via `uvm_config_db`, enables waveform capture, and calls `run_test()` |

### Testbench Data Flow

```
sequence  →  sequencer  →  driver  ──┐
                                      ├──▶  DUT
                            monitor ◀─┘
                               │
                               ├──▶ scoreboard  (checks correctness)
                               └──▶ subscriber  (samples coverage)
```

## 5. Coverage Targets

- **Code coverage:** line, branch, and toggle coverage on the DUT, collected
  via the simulator's native coverage tools.
- **Functional coverage:** covergroup-based sampling of every field in each
  observed transaction (`A`, `B`, `Opcode`, `Result`, `Error`), with the
  operand coverpoints refined to target the specific corner-case values
  called out in Section 3 rather than relying on default auto-binning
  across the full 32-bit range.

## 6. Tools and Technologies

- **Language:** SystemVerilog / UVM
- **Simulator:** Cadence Xcelium (`xrun`)
- **Waveform capture:** SHM database (`$shm_open` / `$shm_probe`), viewed in
  SimVision

## 7. Risk Management

- **DUT/interface signal mismatch:** the DUT's sequential logic references
  `clk`/`rst` without declaring them as module ports in earlier draft
  versions — resolved by explicitly wiring both through the top module and
  interface. Any future DUT revision should be checked against the
  interface's port list before reuse.
- **Reference model independence:** the scoreboard's reference model is
  written from the specification, not derived from the DUT's RTL, to avoid
  a shared blind spot between the two.
- **Known DUT overflow-detection concern:** initial inspection of the
  DUT's overflow logic suggested it may check for opposite-signed operands
  rather than same-signed operands — the condition under which signed
  overflow can actually occur. The reference model implements the
  correct condition, so the directed overflow/underflow sequences are
  expected to be a key discriminator here; see Section 9 once regression
  results are available.

## 8. Regression Tests

| Test | Description |
|---|---|
| `alu_random_test` | Runs `alu_random_sequence` 500 times with fully randomized, unconstrained stimulus |
| `alu_regression_test` | Runs every directed sequence once each: add, sub, and, or, xor, unsupported opcode, overflow, underflow |

_(Pass/fail summary to be filled in after running on the target simulator.)_

## 9. Coverage Reports

_(To be filled in with functional and code coverage percentages once a
regression run has been executed and reports generated.)_

## 10. Verification Results / Bugs Found

_(To be filled in with any scoreboard mismatches observed, including the
exact stimulus that triggered each one and the expected vs. actual
Result/Error values.)_