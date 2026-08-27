

// alu package ===========================================


package alu_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"


	// sequence item + sequencer ----------------------------------------
	`include "alu_sequence_item.sv"
	`include "alu_sequencer.sv"


	// driver + monitor ----------------------------------------
	`include "alu_driver.sv"
	`include "alu_monitor.sv"


	// agent ----------------------------------------
	`include "alu_agent.sv"


	// sequences ----------------------------------------
	`include "alu_random_sequence.sv"
	`include "alu_add_sequence.sv"
	`include "alu_sub_sequence.sv"
	`include "alu_and_sequence.sv"
	`include "alu_or_sequence.sv"
	`include "alu_xor_sequence.sv"
	`include "alu_undefined_opcode_sequence.sv"
	`include "alu_overflow_sequence.sv"
	`include "alu_underflow_sequence.sv"


	// scoreboard + subscriber ----------------------------------------
	`include "alu_scoreboard.sv"
	`include "alu_subscriber.sv"


	// environment ----------------------------------------
	`include "alu_environment.sv"


	// tests ----------------------------------------
  `include "alu_random_test.sv"
	`include "alu_regression_test.sv"
	`include "alu_add_test.sv"
	`include "alu_sub_test.sv"
	`include "alu_and_test.sv"
	`include "alu_or_test.sv"
	`include "alu_xor_test.sv"
	`include "alu_undefined_opcode_test.sv"
	`include "alu_overflow_test.sv"
	`include "alu_underflow_test.sv"


endpackage : alu_pkg