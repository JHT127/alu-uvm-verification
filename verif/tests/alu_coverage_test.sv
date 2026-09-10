// alu coverage test ===========================================


class alu_coverage_test extends uvm_test;


	// Declaring ------------------------------
		alu_environment env;


	// utility macro ----------------------------------------
	`uvm_component_utils(alu_coverage_test)


	// constructor ----------------------------------------
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	// build phase ----------------------------------------
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = alu_environment::type_id::create("env", this);
	endfunction : build_phase


	// run phase ----------------------------------------
	task run_phase(uvm_phase phase);
		alu_coverage_sequence seq;

		phase.raise_objection(this);

		seq = alu_coverage_sequence::type_id::create("seq");
		seq.start(env.agent.sequencer);

		phase.drop_objection(this);
		`uvm_info(get_type_name(), "end of coverage testcase", UVM_LOW)
	endtask : run_phase


endclass : alu_coverage_test
