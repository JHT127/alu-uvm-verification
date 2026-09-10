# ALU UVM regression - Cadence Xcelium
# ===========================================

TEST      ?= alu_random_test
COVERAGE_TEST ?= alu_coverage_test
DUT       ?= buggy
SEED      ?= 1
SEEDS     := 1 42 777 2024 999
ifeq ($(DUT),original)
FLIST     := flist_original.f
else ifeq ($(DUT),correct)
FLIST     := flist_correct.f
else ifeq ($(DUT),buggy)
FLIST     := flist_buggy.f
else
$(error DUT must be original, buggy, or correct)
endif
WORKDIR   := xcelium.d
WAVES_DIR := waves.shm
COV_DIR   := cov_work
TESTLIST  := alu_random_test alu_regression_test alu_add_test alu_sub_test \
             alu_and_test alu_or_test alu_xor_test alu_undefined_opcode_test \
			 alu_overflow_test alu_underflow_test alu_coverage_test \
			 alu_constrained_random_test

XRUN_BASE := -uvm -access +rwc -f $(FLIST)

.PHONY: all help run check regression quick full original buggy correct constrained waves clean summary seeds coverage coverage-correct covreport report

all: run

help:
	@printf "make -C sim <target> [TEST=name] [SEED=n]\n\n"
	@printf "  quick       Run the directed regression on the buggy DUT\n"
	@printf "  buggy       Run the directed regression on alu_buggy.sv\n"
	@printf "  correct     Run the directed regression on alu_correct.sv\n"
	@printf "  original    Show compilation failure of the untouched ALU.sv\n"
	@printf "  full        Run all registered tests\n"
	@printf "  run         Run one test (default: alu_random_test)\n"
	@printf "  constrained Run constrained-random verification\n"
	@printf "  seeds       Run one test across the standard seeds\n"
	@printf "  coverage    Run functional and code coverage\n"
	@printf "  coverage-correct  Run coverage on alu_correct.sv\n"
	@printf "  report      Generate the coverage text report\n"
	@printf "  waves       Open the waveform database\n"
	@printf "  clean       Remove generated simulator output\n"

# compile + elaborate + run in one shot
run:
	xrun $(XRUN_BASE) -svseed $(SEED) +UVM_TESTNAME=$(TEST)

constrained:
	$(MAKE) run DUT=correct TEST=alu_constrained_random_test

buggy:
	$(MAKE) run DUT=buggy TEST=alu_regression_test

correct:
	$(MAKE) run DUT=correct TEST=alu_regression_test

original:
	$(MAKE) run DUT=original TEST=alu_regression_test

# convenience target to run the full directed regression test
regression:
	$(MAKE) run TEST=alu_regression_test

quick: regression

check: regression

full: summary

# open the captured waveform in SimVision
waves:
	simvision $(WAVES_DIR) &

# run every registered test back-to-back, print PASS / FAIL / ERROR per test
summary:
	@for t in $(TESTLIST); do \
		xrun $(XRUN_BASE) -svseed $(SEED) +UVM_TESTNAME=$$t -l run_$$t.log > /dev/null 2>&1; \
		if ! grep -q "UVM_ERROR :" run_$$t.log && ! grep -q "UVM_FATAL :" run_$$t.log; then \
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
		if ! grep -q "UVM_ERROR :" seed_$${s}_$(TEST).log && ! grep -q "UVM_FATAL :" seed_$${s}_$(TEST).log; then \
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
	xrun $(XRUN_BASE) -svseed $(SEED) -coverage all -covoverwrite \
	     -covdut alu_tb_top -covdb $(COV_DIR) \
	     +UVM_TESTNAME=$(COVERAGE_TEST) -l cov_$(COVERAGE_TEST).log

coverage-correct:
	$(MAKE) coverage DUT=correct

# generate a text coverage summary report from the collected database
covreport:
	imc -exec covreport.tcl
	@cat coverage_summary.txt
	@printf "\nDetailed uncovered-bin report:\n"
	@cat coverage_report.txt

report: covreport

# remove simulation/build artifacts
clean:
	rm -rf $(WORKDIR) $(WAVES_DIR) $(COV_DIR) xrun.log xrun.history .simvision *.log coverage_report.txt coverage_summary.txt