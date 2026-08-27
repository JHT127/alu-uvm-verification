# ALU UVM regression - Cadence Xcelium
# ===========================================

TEST      ?= alu_random_test
SEED      ?= 1
SEEDS     := 1 42 777 2024 999
FLIST     := flist.f
WORKDIR   := xcelium.d
WAVES_DIR := waves.shm
COV_DIR   := cov_work
TESTLIST  := alu_random_test alu_regression_test alu_add_test alu_sub_test \
             alu_and_test alu_or_test alu_xor_test alu_undefined_opcode_test \
             alu_overflow_test alu_underflow_test

XRUN_BASE := -uvm -access +rwc -f $(FLIST)

.PHONY: all compile run regression waves clean summary seeds coverage covreport

all: run

# compile + elaborate + run in one shot
run:
	xrun $(XRUN_BASE) -svseed $(SEED) +UVM_TESTNAME=$(TEST)

# convenience target to run the full directed regression test
regression:
	$(MAKE) run TEST=alu_regression_test

# open the captured waveform in SimVision
waves:
	simvision $(WAVES_DIR) &

# run every registered test back-to-back, print PASS / FAIL / ERROR per test
summary:
	@for t in $(TESTLIST); do \
		xrun $(XRUN_BASE) -svseed $(SEED) +UVM_TESTNAME=$$t -l run_$$t.log > /dev/null 2>&1; \
		if ! grep -q "UVM_ERROR :" run_$$t.log; then \
			printf "%-25s ERROR (see run_%s.log)\n" "$$t" "$$t"; \
		else \
			err=$$(grep "UVM_ERROR :" run_$$t.log | awk '{print $$3}'); \
			fat=$$(grep "UVM_FATAL :" run_$$t.log | awk '{print $$3}'); \
			if [ "$$err" = "0" ] && [ "$$fat" = "0" ]; then \
				printf "%-25s PASS\n" "$$t"; \
			else \
				printf "%-25s FAIL\n" "$$t"; \
			fi; \
		fi; \
	done

# run one test across multiple seeds, print PASS / FAIL / ERROR per seed
seeds:
	@for s in $(SEEDS); do \
		xrun $(XRUN_BASE) -svseed $$s +UVM_TESTNAME=$(TEST) -l seed_$${s}_$(TEST).log > /dev/null 2>&1; \
		if ! grep -q "UVM_ERROR :" seed_$${s}_$(TEST).log; then \
			printf "seed=%-8s %-25s ERROR (see seed_%s_%s.log)\n" "$$s" "$(TEST)" "$$s" "$(TEST)"; \
		else \
			err=$$(grep "UVM_ERROR :" seed_$${s}_$(TEST).log | awk '{print $$3}'); \
			fat=$$(grep "UVM_FATAL :" seed_$${s}_$(TEST).log | awk '{print $$3}'); \
			if [ "$$err" = "0" ] && [ "$$fat" = "0" ]; then \
				printf "seed=%-8s %-25s PASS\n" "$$s" "$(TEST)"; \
			else \
				printf "seed=%-8s %-25s FAIL\n" "$$s" "$(TEST)"; \
			fi; \
		fi; \
	done

# run with functional coverage enabled
coverage:
	xrun $(XRUN_BASE) -svseed $(SEED) -coverage functional -covoverwrite \
	     -covdut alu_tb_top -covdb $(COV_DIR) \
	     +UVM_TESTNAME=$(TEST) -l cov_$(TEST).log

# generate a text coverage summary report from the collected database
covreport:
	imc -exec covreport.tcl
	@cat coverage_report.txt
  
# remove simulation/build artifacts
clean:
	rm -rf $(WORKDIR) $(WAVES_DIR) $(COV_DIR) xrun.log xrun.history .simvision *.log coverage_report.txt