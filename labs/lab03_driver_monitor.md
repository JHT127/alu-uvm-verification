# Lab 3 — Building the Driver and Monitor

## Objective

Build the two components that connect the abstract sequence item world to
actual DUT signals: the **driver**, which converts a sequence item into
pin-level stimulus, and the **monitor**, which passively observes the DUT's
pins and packages what it sees back into a sequence item.

## What is a Driver?

The driver extends `uvm_driver`, parameterized with the sequence item type it
handles. It continuously pulls items from the sequencer through the
`seq_item_port`, drives their fields onto the DUT via the virtual interface,
and signals back that each item has been consumed.

## What is a Monitor?

The monitor extends `uvm_monitor`. Unlike the driver, it never writes to the
DUT — it only reads. It samples the interface signals through its own
clocking block, builds a sequence item representing what it observed, and
broadcasts it out through a `uvm_analysis_port` so other components (like the
scoreboard, in Lab 6) can react to it without being directly connected to the
DUT themselves.

## What I Built

- `alu_driver.sv` — extends `uvm_driver #(alu_sequence_item)`. Holds a
  `virtual alu_interface` handle obtained from `uvm_config_db` in
  `build_phase`. In `run_phase`, repeatedly gets the next item from the
  sequencer, drives it onto the DUT through the `drv` modport's clocking
  block, and calls `item_done()`.
- `alu_monitor.sv` — extends `uvm_monitor`. Also gets its virtual interface
  from `uvm_config_db`. Declares a `uvm_analysis_port #(alu_sequence_item)`.
  In `run_phase`, waits out reset, samples `A`/`B`/`Opcode` on one clock
  edge and `Result`/`Error` on the next through the `mon` modport, then
  broadcasts the completed transaction via `port.write()`.

## What I Learned

- **The virtual interface is the actual bridge to the DUT.** Sequence items
  and sequencers never touch real signals — the driver and monitor are the
  only components that do, and they do it exclusively through the
  interface's modports and clocking blocks, never by touching signals
  directly.
- **Driving and sampling on different edges avoids a race.** The driver
  writes through `cb_drv` (negedge), and the monitor reads through `cb_mon`
  (posedge) — this is the same negedge/posedge split from Lab 2, now put to
  use, and it's what keeps the monitor from ever sampling a signal in the
  middle of it changing.
- **Result isn't available on the same edge as the inputs.** Since the ALU
  is a sequential (clocked) design, `Result`/`Error` reflect the *previous*
  cycle's inputs until the next active edge — so the monitor has to sample
  inputs and outputs on two separate posedges rather than grabbing
  everything at once.