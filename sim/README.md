# Simulation

UVM regression is run on Cadence Xcelium (`xrun`). All commands below are
run from inside the `sim/` directory, since `flist.f`'s paths (`./design`,
`./verif`) are relative to it.

## Files

- `flist.f` — file list passed to `xrun` via `-f`. Includes the DUT, the
  interface, the `alu_pkg` package (which pulls in every testbench class
  via `` `include ``), and the top-level testbench module.
- `Makefile` — wraps the `xrun` invocation into simple targets.

## Running

```bash
make               # runs alu_random_test (default)
make regression    # runs alu_regression_test (all directed sequences)
make run TEST=<test_name>   # run any other registered test
make summary       # runs every registered test, prints only PASS/FAIL per test
```

`make summary` writes each test's full log to `run_<test>.log` and prints
a single aligned PASS/FAIL line per test — no compile/elaborate/run
chatter on screen. It relies on scoreboard mismatches being registered as
`` `uvm_error `` (not `` `uvm_info ``) in `alu_scoreboard.sv`, since it checks
the `UVM_ERROR` count in each log to decide pass/fail.

## Waveforms

Waveform capture uses Cadence's native SHM database
(`$shm_open` / `$shm_probe` in `alu_tb_top.sv`), written to `waves.shm`.

```bash
make waves      # opens waves.shm in SimVision
```

## Cleaning up

```bash
make clean      # removes xcelium.d, waves.shm, and all log files
```