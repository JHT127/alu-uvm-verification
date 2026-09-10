# ALU UVM Lab Notes

Labs 1–10 document the incremental construction of the UVM environment. Labs
11–13 document the verification completion work added after the original
component build.

| Lab | Topic | Current source |
|---|---|---|
| 1 | Sequence item and sequencer | `alu_sequence_item.sv`, `alu_sequencer.sv` |
| 2 | Interface and clocking blocks | `alu_interface.sv` |
| 3 | Driver and monitor | `alu_driver.sv`, `alu_monitor.sv` |
| 4 | Agent | `alu_agent.sv` |
| 5 | Directed and random sequences | `verif/alu_sequences/` |
| 6 | Scoreboard and reference model | `alu_scoreboard.sv` |
| 7 | Environment | `alu_environment.sv` |
| 8 | Tests and objections | `verif/tests/` |
| 9 | Testbench top | `alu_tb_top.sv` |
| 10 | Functional coverage subscriber | `alu_subscriber.sv` |
| 11 | Constrained-random verification | `lab11_constrained_random.md` |
| 12 | Coverage closure and reporting | `lab12_coverage_closure.md` |
| 13 | DUT variants and results | `lab13_dut_comparison.md` |

The authoritative run commands and measured results are in the root
`README.md`, `docs/verification_plan.md`, and `docs/dut_comparison.md`.
