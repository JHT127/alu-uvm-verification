# Lab 5 — Building Sequences

## Objective

Build the sequences that generate stimulus for the ALU: a fully random
sequence for general stress testing, one directed sequence per operation
(add, sub, AND, OR, XOR), a sequence for unsupported opcodes, and dedicated
overflow/underflow sequences targeting the exact corner cases from the
verification plan.

## What is a Sequence?

A sequence extends `uvm_sequence #(alu_sequence_item)` and lives in its
`body()` task, where it creates transactions and sends them to the
sequencer using `start_item()` / `finish_item()`. `start_item()` requests
access to the sequencer (blocking until it's this sequence's turn), and
`finish_item()` hands the item off to the driver and blocks until the driver
finishes processing it. Randomizing the item's fields *between* these two
calls (rather than before `start_item()`) is the standard UVM pattern —
`start_item()` reserves the driver's attention, and only then are the actual
values decided.

## What I Built

Nine sequence classes, one per file, all extending
`uvm_sequence #(alu_sequence_item)`:

- `alu_random_sequence.sv` — resets the DUT, then sends a fully randomized
  transaction with no constraint besides `rst == 0`. This is the broad
  stress-test sequence.
- `alu_add_sequence.sv` / `alu_sub_sequence.sv` / `alu_and_sequence.sv` /
  `alu_or_sequence.sv` / `alu_xor_sequence.sv` — each resets the DUT, then
  sends a randomized transaction constrained to its respective opcode
  (`3'b000` through `3'b100`), letting `A`/`B` vary randomly to exercise the
  operation broadly.
- `alu_undefined_opcode_sequence.sv` — constrains `Opcode` to one of the
  three reserved values (`3'b101`, `3'b110`, `3'b111`) to verify the error
  flag gets set for unsupported opcodes.
- `alu_overflow_sequence.sv` — directed (non-random) values: `Opcode ==
  3'b000`, `A == 32'sd2147483647`, `B == 32'd1`, i.e. `32'h7FFFFFFF + 1`,
  matching the overflow corner case from the verification plan.
- `alu_underflow_sequence.sv` — directed values: `Opcode == 3'b001`, `A ==
  -32'sd2147483648`, `B == 32'd1`, i.e. `32'h80000000 - 1`, matching the
  underflow corner case from the verification plan.

Every sequence follows the same two-step pattern: send one item with `rst`
forced high to reset the DUT, wait, then send the actual test item with
`rst == 0`.

## What I Learned

- **Sequences are where the test plan actually becomes code.** Each row in
  the "Selection of Verification Tests" section of the verification plan
  maps almost one-to-one onto one of these sequence files.
- **`start_item()`/`finish_item()` bracket the point of no return.** Once
  `finish_item()` is called, the transaction has already been sent to the
  driver — any last-minute constraint has to happen before that.
- **Directed vs. random isn't a strict either/or.** The overflow/underflow
  sequences use `randomize() with {}` too, just with every field pinned to
  an exact value — the constraint solver still runs, it just has only one
  legal solution. This keeps the code pattern consistent across every
  sequence instead of mixing plain assignment and constrained randomization.