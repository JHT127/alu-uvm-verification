# Lab 1 — Sequence Item & Sequencer

_Written in my own words as a personal build log — not a copy of any internal
lab instructions._

## What I built

- `alu_sequence_item.sv`: extends `uvm_sequence_item`, holds the ALU's input
  fields (`A`, `B`, `Opcode`, `rst`) and output fields (`Result`, `Error`).
  Input fields are `rand` to support randomized stimulus generation.
- `alu_sequencer.sv`: extends `uvm_sequencer #(alu_sequence_item)`, manages
  delivery of sequence items to the driver.

## What I learned

- Why UVM separates the *data* (sequence item) from the *delivery mechanism*
  (sequencer) — this separation is what makes sequences reusable across
  different tests.
- How `uvm_object_utils` / `uvm_field_int` macros enable factory registration
  and automatic field-based operations (copy, compare, print, randomize).

## Notes / things to double check later

- Confirm field widths match the DUT ports exactly once the interface (Lab 2)
  is wired up.
