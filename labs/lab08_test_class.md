# Lab 8 — Building the Test Class

## Objective

Build the test class, the top of the UVM component hierarchy for a single
test run. This is where the environment gets instantiated and a sequence
actually gets started on the sequencer, kicking off real simulation.

## What is a Test?

A test extends `uvm_test` and is the entry point UVM starts when a
simulation runs (selected via `+UVM_TESTNAME` or the equivalent config).
It's responsible for building the environment in `build_phase` and, in
`run_phase`, creating and starting one or more sequences on the
environment's sequencer. Objections (`raise_objection` / `drop_objection`)
are what tell UVM's phasing mechanism the test is still active — without
raising one, `run_phase` would be considered instantly complete and the
simulation would end before any stimulus is sent.

## What I Built

- `alu_random_test.sv` — extends `uvm_test`. Builds an `alu_environment` in
  `build_phase`. In `run_phase`, raises an objection, creates an
  `alu_random_sequence`, starts it on `env.agent.sequencer` 500 times in a
  loop, then drops the objection.
- `alu_regression_test.sv` — extends `uvm_test`. Same environment build.
  In `run_phase`, raises an objection, then sequentially creates and starts
  every directed sequence from Lab 5 (add, sub, and, or, xor, undefined
  opcode, overflow, underflow) on the sequencer, one after another, then
  drops the objection. This exercises every corner case from the
  verification plan in a single run.

## What I Learned

- **Objections are what keep the simulation alive.** `run_phase` is a task,
  and UVM doesn't wait around for it by default — the objection mechanism
  is the explicit signal that says "don't end the run phase yet, real work
  is happening." Forgetting to raise one is a classic way to get a test that
  "passes" instantly by doing nothing at all.
- **The test is the only place sequences get started.** Everything below it
  (env, agent, scoreboard, sequencer) is reusable structure — the test is
  what decides *which* stimulus actually runs, which is why a new test class
  is the natural way to add a new test scenario, instead of modifying the
  environment itself.
- **A regression test is just a test that runs many sequences back-to-back.**
  There's nothing structurally special about it — it's the same
  `raise_objection` / start sequences / `drop_objection` pattern as the
  random test, just calling `start()` multiple times with different sequence
  types instead of looping the same one.