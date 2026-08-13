# Lab 7 — Building the Environment Class

## Objective

Build the environment, the component that instantiates the agent,
scoreboard, and coverage subscriber, and wires the monitor's observed
transactions to both of them.

## What is an Environment?

The environment extends `uvm_env` and sits one level above the agent — it's
the component responsible for assembling everything needed to actually run
a test: the agent (stimulus + observation), the scoreboard (checking), and
the subscriber (coverage). It doesn't generate stimulus or make pass/fail
decisions itself; it just builds the pieces and connects them so data flows
correctly between them.

## Why Fan Out the Monitor's Port?

The monitor's analysis port isn't a point-to-point connection — a single
`uvm_analysis_port` can be connected to multiple `uvm_analysis_imp`/
`uvm_analysis_export` targets at once. Here, every transaction the monitor
observes gets broadcast to both the scoreboard (which checks correctness)
and the subscriber (which samples coverage), without the monitor needing to
know or care that both exist.

## What I Built

- `alu_environment.sv` — extends `uvm_env`. Declares handles for
  `alu_agent`, `alu_scoreboard`, and `alu_subscriber`. In `build_phase`,
  creates all three through the factory with `this` as parent. In
  `connect_phase`, connects `agent.monitor.port` to both `scoreboard.exp`
  and `subscriber.analysis_export`.

## What I Learned

- **The environment is purely structural, same as the agent was.** No new
  behavior gets written here — it's entirely about instantiation and
  wiring.
- **One analysis port, many subscribers.** This is the first time I've
  connected a single port to more than one destination — it's what lets the
  scoreboard and the coverage collector both react to the exact same stream
  of transactions independently, without either one affecting the other.
- **Build order matters, connect order doesn't (much).** All three
  components have to exist (`build_phase`) before any of them can be wired
  together (`connect_phase`) — same principle as the agent's
  driver/sequencer connection in Lab 4, just one level higher in the
  hierarchy.