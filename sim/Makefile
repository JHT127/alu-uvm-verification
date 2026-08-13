# ALU UVM regression - Cadence Xcelium
# ===========================================

TEST      ?= alu_random_test
FLIST     := flist.f
WORKDIR   := xcelium.d
WAVES_DIR := waves.shm
TESTLIST  := alu_random_test alu_regression_test

XRUN_BASE := -uvm -access +rwc -f $(FLIST)

.PHONY: all compile run regression waves clean summary

all: run

# compile + elaborate + run in one shot
run:
	xrun $(XRUN_BASE) +UVM_TESTNAME=$(TEST)

# convenience target to run the full directed regression test
regression:
	$(MAKE) run TEST=alu_regression_test

# open the captured waveform in SimVision
waves:
	simvision $(WAVES_DIR) &

# run every registered test back-to-back, print only PASS/FAIL per test
summary:
	@for t in $(TESTLIST); do \
		xrun $(XRUN_BASE) +UVM_TESTNAME=$$t -l run_$$t.log > /dev/null 2>&1; \
		err=$$(grep "UVM_ERROR :" run_$$t.log | awk '{print $$3}'); \
		fat=$$(grep "UVM_FATAL :" run_$$t.log | awk '{print $$3}'); \
		if [ "$$err" = "0" ] && [ "$$fat" = "0" ]; then \
			printf "%-25s PASS\n" "$$t"; \
		else \
			printf "%-25s FAIL\n" "$$t"; \
		fi; \
	done

# remove simulation/build artifacts
clean:
	rm -rf $(WORKDIR) $(WAVES_DIR) xrun.log xrun.history .simvision *.log