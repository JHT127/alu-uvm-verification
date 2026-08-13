# Lab 10 — Building the Subscriber

## Objective

Build the subscriber: the component that receives the same stream of
transactions the scoreboard sees, and instead of checking correctness,
samples functional coverage to measure how thoroughly the ALU's
functionality has actually been exercised.

## What is a Subscriber?

A subscriber extends `uvm_subscriber #(T)`, a UVM base class purpose-built
for components that passively consume transactions without driving
anything back. It already provides an `analysis_export` out of the box —
that's what the environment connected to in Lab 7 alongside the scoreboard
— so all a subscriber needs to implement is the `write()` callback.

## What is a Covergroup?

A covergroup is SystemVerilog's native functional coverage construct. Each
`coverpoint` tracks the range of values a given expression has taken across
every `sample()` call, and `get_coverage()` reports what percentage of the
defined coverage space has actually been hit. Declaring the covergroup
inside the class lets its coverpoints reference the class's own member
(`sub`) directly.

## What I Built

- `alu_subscriber.sv` — extends `uvm_subscriber #(alu_sequence_item)`.
  Declares an internal `alu_sequence_item sub` used purely as coverage
  storage, and a covergroup `aluCoverage` with one coverpoint per field
  (`A`, `B`, `Opcode`, `Result`, `Error`). The constructor instantiates both
  `sub` and `aluCoverage`. `write()` copies each field from the incoming
  transaction into `sub` and calls `aluCoverage.sample()`. `report_phase`
  prints the final coverage percentage at the end of simulation.

## What I Learned

- **The subscriber and the scoreboard are peers, not a pipeline.** Both
  receive the exact same transactions from the monitor at the same time
  (via the fan-out we built in Lab 7) — the subscriber doesn't wait for the
  scoreboard to finish checking, and neither depends on the other's result.
- **Sampling needs a stable snapshot, not a live reference.** The coverpoints
  reference `sub`'s fields rather than the incoming argument `t` directly,
  so `sample()` always measures a value that was deliberately copied in,
  not something that could change mid-sample.
- **Coverage answers a different question than the scoreboard does.** The
  scoreboard already tells us *if* the DUT is behaving correctly; the
  subscriber tells us whether our stimulus was actually thorough enough for
  that verdict to mean anything — e.g., if `Opcode` coverage shows the
  overflow/underflow paths were only hit once each, that's a sign our
  sequences (Lab 5) may need to run more regression passes, not that the
  DUT itself is necessarily fine.