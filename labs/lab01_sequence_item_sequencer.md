# Lab 1 — Building the Sequence Item and Sequencer

## Objective

Build the two foundational UVM components responsible for generating and
delivering stimulus to the ALU: the **sequence item**, which represents a
single transaction, and the **sequencer**, which manages the flow of these
transactions to the driver.

## What is a Sequence Item?

A sequence item is the transaction class used to model a single exchange with
the DUT. It extends `uvm_sequence_item` and holds both the input fields that
stimulate the ALU (`A`, `B`, `Opcode`, `rst`) and the output fields that
capture its response (`Result`, `Error`).

Bundling inputs and outputs into one object matters because it lets the rest
of the environment treat a "transaction" as a single unit end to end — the
same object that carries randomized stimulus into the driver can later be
compared, printed, or logged with the DUT's response attached.

## What is a Sequencer?

The sequencer sits between sequences (which generate items) and the driver
(which applies them to the DUT). It extends `uvm_sequencer`, parameterized
with the sequence item type it manages, and is responsible for handing items
to the driver one at a time, in order, whenever the driver requests one.

## What I Built

- `alu_sequence_item.sv` — extends `uvm_sequence_item`. Declares `rand`
  fields for the ALU's inputs (`rst`, `A`, `B`, `Opcode`) so they can be
  randomized by later sequences, plus non-random fields for the DUT's outputs
  (`Result`, `Error`). Registered with the factory using
  `uvm_object_utils_begin/end` and `uvm_field_int` macros for each field.
- `alu_sequencer.sv` — extends `uvm_sequencer #(alu_sequence_item)`.
  Registered with the factory using `uvm_component_utils`.

## What I Learned

- **Data and delivery are kept separate.** The sequence item is just a bag of
  fields — it doesn't know how or when it gets sent anywhere. The sequencer
  is the part that manages sending items out, one at a time, to whatever is
  asking for them (the driver). Splitting these means the same item can be
  reused by many different test scenarios later.
- **The macros save a lot of manual work.** Instead of writing my own
  `copy()`, `compare()`, or `print()` functions for the class, the
  `uvm_field_int` macros generate that behavior automatically for every field
  I register.
- **The sequencer has no ALU knowledge in it at all.** At this stage it's
  just plumbing — it doesn't decide what values to send, it just passes
  along whatever a sequence gives it. The actual "what to test" logic comes
  later in Lab 5.

## Notes for Later

- Double check field widths/polarity against the DUT ports once the
  interface is built (Lab 2).
- `rst` is currently randomizable — worth revisiting whether reset should be
  driven separately/deterministically rather than randomized like a data field.