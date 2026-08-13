# Lab 4 — Building the Agent

## Objective

Build the agent, the component that bundles the driver, sequencer, and
monitor together and wires them into a single reusable unit, and connect the
driver to the sequencer over TLM.

## What is an Agent?

An agent extends `uvm_agent` and groups everything responsible for one
interface's worth of stimulus and observation: the sequencer (delivers
items), the driver (drives them onto the DUT), and the monitor (observes the
DUT's response). Bundling these together means the environment only has to
instantiate and configure one object instead of managing three separately.

## Active vs. Passive

An agent can run in `UVM_ACTIVE` or `UVM_PASSIVE` mode:

- **Active** — creates the driver and sequencer in addition to the monitor,
  so it can both stimulate and observe the DUT.
- **Passive** — creates only the monitor, so it can observe without driving
  anything. This is useful for things like a second agent watching a bus
  without ever putting traffic on it.

The monitor is always created regardless of mode, since observation is
useful in either case.

## What I Built

- `alu_agent.sv` — extends `uvm_agent`. Declares handles for `alu_driver`,
  `alu_sequencer`, and `alu_monitor`. In `build_phase`, creates the driver
  and sequencer only when `get_is_active() == UVM_ACTIVE`, and always
  creates the monitor. In `connect_phase`, connects
  `driver.seq_item_port` to `sequencer.seq_item_export`, again only when
  active (there's nothing to connect in passive mode, since no driver
  exists).

## What I Learned

- **The agent is a structural component, not a behavioral one.** It doesn't
  generate stimulus or check anything itself — it just assembles the pieces
  built in Labs 1–3 into one reusable block.
- **Active/passive is what makes an agent reusable across different roles.**
  The same `alu_agent` class could later be reused as a passive-only checker
  agent somewhere else, without rewriting driver/monitor code, just by
  changing its configured mode.
- **TLM connections must happen in `connect_phase`, not `build_phase`.**
  Components need to exist before they can be wired together, so the
  factory `create()` calls happen in `build_phase` and the port-to-export
  connection happens one phase later in `connect_phase`.