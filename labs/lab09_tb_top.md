# Lab 9 — Building the Testbench Top Module

## Objective

Build the top-level module that ties everything together: generates the
clock, instantiates the interface and the DUT, publishes the interface
handle to the UVM environment through `uvm_config_db`, enables waveform
dumping, and kicks off the test with `run_test()`.

## What Belongs at the Top?

Everything below this file (sequence item, sequencer, driver, monitor,
agent, sequences, scoreboard, environment, tests) is pure UVM class code —
none of it can exist in isolation without something instantiating an actual
clock and an actual DUT. The top module is that "something": it's plain
SystemVerilog, not a UVM component, and it's the one place where the
class-based UVM world meets real, physical simulation signals.

## Publishing the Interface

UVM components can't be handed a virtual interface as a constructor
argument the way plain modules pass ports around — instead, the top module
writes the interface handle into `uvm_config_db`, and any component that
needs it (driver, monitor, and now the sequences too) reads it back out
using the same key (`"vif"`). This is what actually connects the class-based
testbench to the physical interface instance.

## What I Built

- `alu_tb_top.sv` — generates `clk` with a 10-time-unit period. Instantiates
  `alu_interface` and the `alu` DUT, connecting both to the same `clk`/`rst`
  nets. Publishes the interface to `uvm_config_db` at the root scope so
  every component (and, per Lab 5, every sequence) can retrieve it. Enables
  waveform dumping, then calls `run_test("alu_random_test")` to kick off
  the default test.

## What I Learned

- **The DUT and the interface are wired to the exact same physical
  `clk`/`rst` nets** — the interface doesn't generate its own timing, it's
  purely a bundling/synchronization construct around signals that already
  exist at the top level.
- **`uvm_config_db::set` at the root (`uvm_root::get()`, `"*"`) makes the
  interface visible everywhere**, which is exactly why the sequences from
  Lab 5 were able to `get()` the same `"vif"` key without needing it passed
  down explicitly through the agent/environment hierarchy.
- **Reset is now entirely the driver's responsibility, not the top
  module's.** Since Lab 5, every sequence already begins by driving `rst`
  high then low through the driver's clocking block — so the top module
  doesn't need (and shouldn't have) its own separate procedural block also
  driving `rst`, since that would create two different drivers fighting
  over the same net.