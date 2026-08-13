# Lab 6 — Building the Scoreboard

## Objective

Build the scoreboard: the component that receives transactions from the
monitor, computes what the DUT *should* have produced using an independent
reference model, and compares the two. This is the first point in the
testbench where a real bug in the DUT can actually be caught.

## What is a Scoreboard?

The scoreboard extends `uvm_scoreboard` and acts as the checker of the
environment. It never touches the DUT directly — it only receives completed
transactions from the monitor (through an analysis port) and judges them
against its own expectation of correct behavior.

## What is a Reference Model?

The reference model is a from-scratch reimplementation of the ALU's intended
behavior, written independently of the DUT's actual RTL. It takes the same
inputs (`A`, `B`, `Opcode`) and computes the `Result`/`Error` that a
*correct* ALU would produce. The scoreboard compares this against what the
monitor actually observed on the DUT's outputs — any mismatch is a real bug.

## What I Built

- `alu_scoreboard.sv` — extends `uvm_scoreboard`. Receives transactions via
  a `uvm_analysis_imp#(alu_sequence_item, alu_scoreboard)`, whose `write()`
  callback pushes each item onto an internal queue. `run_phase` continuously
  pops items off that queue, runs them through the `alu_rf` reference model
  task to build the expected transaction, and compares the two with
  `is_equal()`, logging a pass or fail for each.

## What I Learned

- **The scoreboard is the first place a bug can actually surface.**
  Everything built in Labs 1–5 only gets stimulus *into* the DUT — this is
  the first component that judges what came *out*.
- **The reference model has to be trustworthy on its own.** If the reference
  model has the same bug as the DUT, the scoreboard will never catch it —
  which is exactly why it's written independently instead of copying the
  DUT's logic. This matters a lot here, since the DUT's own overflow
  detection is likely backwards (checks opposite-sign operands instead of
  same-sign operands) — the reference model here uses the correct condition,
  so the scoreboard should actually flag that mismatch once everything is
  wired up.
- **An analysis port's `write()` is a callback, not something you call
  yourself.** The monitor calls `port.write(item)`, and because the
  scoreboard's `exp` port is a `uvm_analysis_imp`, that call is automatically
  routed into the scoreboard's own `write()` function — no polling needed on
  that side.