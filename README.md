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
design/     Original, buggy, and corrected DUT variants
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
The short discussion script is [`docs/dut_comparison.md`](docs/dut_comparison.md).
The lab notes are indexed in [`labs/README.md`](labs/README.md).

## DUT Demonstration Versions

The repository keeps three deliberately separate versions so the verification
story is easy to demonstrate:

| File | Purpose | Expected result |
|---|---|---|
| `design/ALU.sv` | Original supplied source | Does not compile: `clk` and `rst` are used but not declared as ports |
| `design/alu_buggy.sv` | Original source with only `clk` and `rst` added | Compiles; scoreboard finds the signed `Error` bug |
| `design/alu_correct.sv` | Clock/reset interface plus corrected signed error logic | Directed checks pass |

Run each demonstration from the repository root:

```sh
make -C sim original   # expected compile failure: missing clk/rst declarations
make -C sim buggy      # expected scoreboard failures: supplied DUT bug
make -C sim correct     # expected: 8 checks pass, 0 fail
```

The testbench is intentionally not changed to hide failures. The scoreboard
calculates the expected result independently from the DUT.

## Status

The UVM environment runs directed, unconstrained-random, constrained-random,
and coverage-driven tests with Cadence Xcelium. The supplied DUT is kept as a
bug target; the corrected DUT is available for a clean regression.


## Bugs found

The current DUT defect is an incorrect signed arithmetic `Error` condition. It is
exposed by these directed cases:

1. `32'h7fffffff + 32'd1` produces the wrapped result but leaves `Error=0`.
2. `32'h80000000 - 32'd1` produces the wrapped result but leaves `Error=0`.

The fixed-seed random test also found 41 mismatches in 500 checks (459 passed),
including both missed overflow/underflow errors and false error assertions. The
defect remains in `design/alu_buggy.sv` because this repository verifies the
provided DUT before demonstrating the corrected implementation.

## How to run

Run from the repository root:

```sh
make -C sim quick
make -C sim run TEST=alu_random_test SEED=42
make -C sim full DUT=correct
make -C sim constrained
make -C sim seeds TEST=alu_random_test
make -C sim coverage-correct
make -C sim report
make -C sim waves
make -C sim clean
```

The simulator is Cadence Xcelium. `waves` requires SimVision.

For a short submission demonstration, run `make -C sim full DUT=correct`,
then show `make -C sim coverage-correct` and `make -C sim report`. To demonstrate
bug detection separately, run `make -C sim buggy` and explain the scoreboard
mismatches rather than treating them as testbench failures.

The constrained-random workflow runs on the corrected DUT by default. It
generates 800 transactions across legal operations, reserved opcodes, guaranteed
addition and subtraction error regions, logical operations, and safe arithmetic.
Use `make -C sim run DUT=buggy TEST=alu_constrained_random_test` to demonstrate
that the same constraints expose the supplied DUT defect.

`make -C sim coverage-correct` uses `alu_correct.sv`. The generic target keeps
the selected DUT, for example:

```sh
make -C sim coverage DUT=correct
make -C sim report
```

The functional coverage goal is 100% of gradeable bins. The corrected DUT
achieves `100.00% (89/89)`. RTL code coverage is a separate metric: its block
coverage is `100.00% (9/9)`, but the overall RTL metrics are not all 100%, so
remaining holes must be explained rather than hidden.


