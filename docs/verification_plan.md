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
- Arithmetic operands and opcode values are randomized only within the
  scenario currently under test.
- Reset is driven deterministically at the start of each sequence.
- Coverage-impossible combinations are excluded with documented `ignore_bins`.

## 2. Design Overview

### DUT Variants Used For Demonstration

Three RTL files are retained deliberately:

- `design/ALU.sv` is the original supplied source. It references `clk` and
  `rst` without declaring them, so compilation fails before functional
  verification can begin.
- `design/alu_buggy.sv` adds those two ports without changing the supplied
  operation logic. It compiles and allows the scoreboard to expose the signed
  arithmetic error-detection defect.
- `design/alu_correct.sv` keeps the same interface and operations, but uses the
  correct signed overflow/underflow conditions and clears `Error` for every
  valid non-error operation.

The Makefile selects the file list with `DUT=original`, `DUT=buggy`, or
`DUT=correct`; this keeps each comparison reproducible.

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
| `rst` | 1 | input | Asynchronous active-high reset of internal state |
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
6. **Constrained-random testing** — 800 transactions divided across legal
  operations, reserved opcodes, guaranteed addition overflow, guaranteed
  subtraction underflow, logical operations, and bounded safe arithmetic.

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
| **Sequences** (`verif/alu_sequences/`) | Directed operation/error sequences, unconstrained random, coverage-directed, and constrained-random sequences |
| **Scoreboard** (`alu_scoreboard`) | Receives monitored transactions, computes expected results via an independent reference model, and compares against the DUT's actual output |
| **Subscriber** (`alu_subscriber`) | Receives the same monitored transactions and samples functional coverage on `A`, `B`, `Opcode`, `Result`, and `Error` |
| **Environment** (`alu_environment`) | Instantiates the agent, scoreboard, and subscriber; fans the monitor's output out to both |
| **Tests** (`verif/tests/`) | Standalone operation/error tests, directed regression, unconstrained random, coverage, and constrained-random tests |
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
| `alu_coverage_test` | Drives explicit boundary, sign, logical-pattern, reserved-opcode, and cross-coverage stimulus |
| `alu_constrained_random_test` | Runs 800 constrained-random transactions across six scenario classes |

With Xcelium seed `1`, the directed regression produces 6 passing checks and 2
expected scoreboard failures. The passing checks cover addition, subtraction, AND,
OR, XOR, and unsupported opcode handling. With random seed `42`, the random test
produces 459 passing checks and 41 failures in 500 checks.

With `DUT=correct`, the directed regression produces 8 passing checks and 0
failures. This is the expected result after fixing the DUT; it does not change
the original bug finding recorded below.

With `DUT=correct`, `alu_constrained_random_test` produces 800 passing checks
and 0 failures. With `DUT=buggy`, the same test produces 279 scoreboard failures,
including missed arithmetic errors and false error assertions.

## 9. Coverage Reports

Coverage collection is supported by `make -C sim coverage`; the generated database
is local simulator output and should be regenerated rather than committed. With
the corrected DUT, the dedicated coverage test closes all 89 gradeable functional
bins. The excluded combinations are reserved opcode with `Error=0` and logical
operation with `Error=1`; both contradict the specification. Code coverage remains
a separate metric and must be reported with its uncovered RTL paths explained.

## 10. Verification Results / Bugs Found

| Case | Stimulus | DUT | Expected |
|---|---|---|---|
| Signed addition overflow | `A=32'h7fffffff`, `B=32'd1`, `Opcode=3'b000` | `Result=32'h80000000`, `Error=0` | `Result=32'h80000000`, `Error=1` |
| Signed subtraction underflow | `A=32'h80000000`, `B=32'd1`, `Opcode=3'b001` | `Result=32'h7fffffff`, `Error=0` | `Result=32'h7fffffff`, `Error=1` |

The verification environment exposes the DUT's incorrect signed arithmetic error
condition without silently repairing it. The random failures include both missed
overflow/underflow errors and false error assertions.