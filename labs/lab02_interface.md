# Lab 2 — Building the Design Interface

## Objective

Build the SystemVerilog interface that connects the ALU DUT to the
testbench, including the clocking blocks and modports needed to keep driver
and monitor timing correct and their signal access separated.

## What is an Interface?

An interface groups all the signals shared between the DUT and the
testbench into a single bundle. Instead of connecting each signal
individually wherever it's needed, the interface is instantiated once and
passed around, which keeps the connectivity manageable as the testbench
grows.

## What are Clocking Blocks?

A clocking block ties a group of signals to a specific clock edge, defining
exactly when they should be sampled or driven relative to that edge. This
matters because the driver and the monitor need to interact with the DUT at
different points in the clock cycle:

- The **driver** needs to change inputs *before* the DUT samples them, so it
  drives on the negative edge — this gives the new values time to settle
  before the DUT's next active edge.
- The **monitor** needs to observe signals *after* the DUT has reacted, so it
  samples on the positive edge.

## What are Modports?

A modport restricts what a given component can see and do through the
interface. The driver's modport only exposes the driver's clocking block (so
it can only drive what it's supposed to drive), and the monitor's modport
only exposes the monitor's clocking block (so it can only observe, never
drive). This keeps responsibilities cleanly separated and prevents,
for example, the monitor from accidentally driving a signal.

## What I Built

- `alu_interface.sv` — declares the ALU signals (`A`, `B`, `Opcode`,
  `Result`, `Error`), takes `clk` and `rst` as interface ports, and defines:
  - `cb_drv`, a negedge-clocked block driving `rst`, `A`, `B`, `Opcode`
  - `cb_mon`, a posedge-clocked block sampling `A`, `B`, `Opcode`, `Result`,
    `Error`
  - `drv` and `mon` modports exposing each clocking block to the
    corresponding component

## What I Learned

- **Edge choice isn't arbitrary.** Driving on the negedge and sampling on
  the posedge is what avoids race conditions between the testbench and the
  DUT — the driver's new values are stable well before the DUT's clock edge
  actually samples them.
- **Modports are about discipline, not just syntax.** Anyone using the `drv`
  modport literally cannot touch the monitor's signals, and vice versa. This
  stops accidental cross-wiring as more testbench components get added.
- **Reset needs to go through the clocking block too.** Driving `rst`
  directly instead of through `cb_drv` would bypass the same timing
  discipline that keeps `A`, `B`, and `Opcode` race-free — so `rst` is driven
  through the driver's clocking block just like the other driver-controlled
  signals, and exposed the same way through the `drv` modport.