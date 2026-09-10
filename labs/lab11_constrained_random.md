# Lab 11 — Constrained-Random Verification

## Objective

Use random stimulus while controlling the scenario being exercised. This
combines broad exploration with deliberate coverage of legal, reserved,
overflow, underflow, logical, and safe-arithmetic cases.

## What I Built

`alu_constrained_random_sequence.sv` generates 800 transactions in six
scenario groups:

- 100 legal-operation transactions
- 100 reserved-opcode transactions
- 200 guaranteed addition overflow transactions
- 200 guaranteed subtraction overflow/underflow transactions
- 100 logical-operation transactions
- 100 bounded safe-arithmetic transactions

The constraints keep operands random but select meaningful regions. For
example, addition overflow uses same-sign operands with sufficiently large
magnitudes, while safe arithmetic uses bounded values that cannot overflow.

## How to Run

```sh
make -C sim constrained
```

The shortcut runs the corrected DUT. To demonstrate bug detection:

```sh
make -C sim run DUT=buggy TEST=alu_constrained_random_test
```

The corrected DUT passes 800/800 checks. The buggy DUT produces scoreboard
mismatches, including missed and false arithmetic error indications.

## Discussion Point

Unconstrained random testing is useful for broad stress. Constraints make rare
or important scenarios reproducible and measurable without hard-coding every
transaction.
