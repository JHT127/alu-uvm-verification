# Simulation

UVM regression is run on Cadence Xcelium (`xrun`). Commands may be run from
the repository root with `make -C sim ...`, or from this directory with
`make ...`.

## Files

- `flist_original.f`, `flist_buggy.f`, `flist_correct.f` — select the DUT
  variant passed to `xrun`.
- `Makefile` — wraps the `xrun` invocation into simple targets.

## Running

```bash
make quick                         # directed regression on the selected DUT
make correct                       # directed regression on alu_correct.sv
make constrained                   # constrained-random test on alu_correct.sv
make full DUT=correct              # every registered test on corrected DUT
make run TEST=<test_name> DUT=buggy
make seeds TEST=<test_name> DUT=correct
make coverage-correct              # code and functional coverage
make report                        # generate both coverage reports
make summary DUT=correct           # aligned PASS/FAIL summary
```

`DUT` may be `original`, `buggy`, or `correct`. The original source is
expected to fail compilation; the buggy source is expected to produce
scoreboard failures; the corrected source is the clean submission baseline.

`make summary` writes each test's full log to `run_<test>.log` and prints a
single aligned PASS/FAIL line per test.

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