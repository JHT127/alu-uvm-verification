# Lab 13 — DUT Comparison and Verification Results

## Objective

Separate interface repair from behavioral repair and show how the scoreboard
finds the supplied DUT defects.

## DUT Versions

- `design/ALU.sv`: original supplied source; compilation fails because `clk`
  and `rst` are used but not declared.
- `design/alu_buggy.sv`: adds those ports only; simulation runs and exposes the
  signed `Error` defect.
- `design/alu_correct.sv`: preserves the interface and fixes the arithmetic
  error condition.

## How to Run

```sh
make -C sim original
make -C sim buggy
make -C sim correct
```

The original command is expected to fail compilation. The buggy command
produces scoreboard failures. The corrected command passes the directed test.
The full corrected regression is:

```sh
make -C sim full DUT=correct
```

## Discussion Point

A verification engineer should not repair a failing result in the scoreboard.
The expected value comes from the specification; the actual value comes from
the DUT. A mismatch is evidence to report and explain.
