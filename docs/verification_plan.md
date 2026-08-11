# ALU Verification Plan

> Written independently based on what I learned during the internship —
> not a copy of any internal training material.

## 1. Introduction

- **Purpose:** Verify the functional correctness of a 32-bit ALU supporting
  addition, subtraction, bitwise AND/OR/XOR, and error detection.
- **Scope:** Black-box, top-level verification of the ALU module — inputs and
  outputs only, no internal signal probing.

## 2. DUT Overview

- 32-bit operands `A`, `B`
- 3-bit `Opcode` selects the operation
- 32-bit `Result`, 1-bit `Error` flag
- Error flag indicates arithmetic overflow/underflow or unsupported opcode

(See `design/alu.sv` for the port list and `docs/block_diagram.png` for the
black-box diagram.)

## 3. Verification Strategy

- **Methodology:** UVM testbench with driver, monitor, scoreboard (containing a
  self-written reference model), and functional coverage collector (subscriber).
- **Approach:** Directed tests for known corner cases, followed by constrained
  random testing for broader coverage.

## 4. Test Plan

### 4.1 Addition
- Basic positive-number addition
- Addition of negative numbers
- Addition causing overflow (e.g. `32'h7FFFFFFF + 1`)

### 4.2 Subtraction
- Basic positive-number subtraction
- Subtraction of negative numbers
- Subtraction causing underflow (e.g. `32'h80000000 - 1`)

### 4.3 Bitwise AND / OR / XOR
- Various bit patterns
- All-ones / all-zeros operands
- Alternating patterns: `32'hAAAAAAAA` vs `32'h55555555`

### 4.4 Error Handling
- Unsupported opcodes (`3'b101`, `3'b110`, `3'b111`)
- Overflow/underflow flag correctness
- Error flag behavior on the operation *following* an error (does it clear?)

### 4.5 Boundary / Corner Cases
- Min/max operand values
- Zero and one operand edge cases
- Sign-bit toggling operations

### 4.6 Randomized Testing
- Constrained-random A/B/Opcode combinations for stress testing

## 5. Coverage Goals

- **Code coverage:** line, branch, toggle, FSM (if applicable)
- **Functional coverage:** opcode coverage, operand corner-case coverage,
  cross-coverage of opcode × sign combinations, error-flag coverage

## 6. Testbench Architecture

_(Fill in as components are built — see `tb/` and `labs/` for build history.)_

| Component | File | Status |
|---|---|---|
| Sequence Item | `tb/alu_sequence_item.sv` | ⬜ |
| Sequencer | `tb/alu_sequencer.sv` | ⬜ |
| Interface | `tb/alu_interface.sv` | ⬜ |
| Driver | `tb/alu_driver.sv` | ⬜ |
| Monitor | `tb/alu_monitor.sv` | ⬜ |
| Agent | `tb/alu_agent.sv` | ⬜ |
| Sequences | `tb/alu_sequences/` | ⬜ |
| Scoreboard | `tb/alu_scoreboard.sv` | ⬜ |
| Environment | `tb/alu_env.sv` | ⬜ |
| Test | `tb/alu_test.sv` | ⬜ |
| TB Top | `tb/alu_tb_top.sv` | ⬜ |
| Subscriber (coverage) | `tb/alu_subscriber.sv` | ⬜ |

## 7. Tools and Technologies

- Language: SystemVerilog / UVM
- Simulator: _(fill in — e.g. Questa, VCS, EDA Playground)_

## 8. Risk Management

_(Note any known limitations, unclear spec areas, or risk areas discovered
during verification — e.g. ambiguity in overflow detection logic.)_

## 9. Regression Tests

_(List of tests run in regression, and pass/fail summary once available.)_

## 10. Coverage Reports

_(Link or embed coverage summary once generated.)_

## 11. Verification Results / Bugs Found

_(Document any DUT bugs found, with the stimulus that exposed them and the
expected vs. actual behavior.)_
