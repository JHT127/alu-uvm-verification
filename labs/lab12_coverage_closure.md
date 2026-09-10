# Lab 12 — Coverage Closure and Reporting

## Objective

Measure whether the stimulus covers the verification plan, then add stimulus
for meaningful uncovered cases instead of relying on transaction count alone.

## What I Built

`alu_subscriber.sv` covers:

- signed operand boundaries and signs
- zero, one, all-zero, all-one, and alternating patterns
- every legal and reserved opcode class
- result boundaries and error outcomes
- operation/error, operation/sign, and operation/pattern crosses

The dedicated `alu_coverage_test` supplies explicit values for these bins. The
coverage model excludes only impossible specification combinations:
reserved opcode with `Error=0`, and logical operation with `Error=1`.

## How to Run

```sh
make -C sim coverage-correct
make -C sim report
```

The corrected DUT reaches 100% of the 89 gradeable functional bins. RTL code
coverage is reported separately; functional coverage does not imply that every
RTL statement, expression, or toggle has been exercised.

## Discussion Point

A coverage percentage is meaningful only when the bins represent real
requirements. Impossible behavior should be excluded with a documented reason,
not forced with artificial stimulus.
