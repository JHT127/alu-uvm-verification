# Testbench Components

UVM testbench for the ALU DUT, built incrementally.

| File | Purpose |
|---|---|
| `alu_sequence_item.sv` | Transaction: inputs + outputs exchanged with the DUT |
| `alu_sequencer.sv` | Delivers sequence items to the driver |
| `alu_interface.sv` | SV interface binding TB signals to DUT ports |
| `alu_driver.sv` | Drives sequence items onto the DUT interface |
| `alu_monitor.sv` | Passively observes DUT interface, packages observed transactions |
| `alu_agent.sv` | Bundles sequencer + driver + monitor |
| `alu_sequences/` | Directed and randomized stimulus sequences |
| `alu_scoreboard.sv` | Reference model + comparison against DUT output |
| `alu_env.sv` | Instantiates and connects agent + scoreboard + subscriber |
| `alu_test.sv` | Configures environment and starts sequences |
| `alu_tb_top.sv` | Top-level module: clock/reset generation, DUT + interface instantiation |
| `alu_subscriber.sv` | Functional coverage collector |

Add each file as it's built, and check it off in `docs/verification_plan.md`.
