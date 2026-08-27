// alu underflow test ===========================================
class alu_underflow_test extends uvm_test;
	alu_environment env;
	alu_underflow_sequence seq;

	`uvm_component_utils(alu_underflow_test)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = alu_environment::type_id::create("env", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
phase.phase_done.set_drain_time(this, 30);
phase.phase_done.set_drain_time(this, 30);
		seq = alu_underflow_sequence::type_id::create("seq");
		seq.start(env.agent.sequencer);
		phase.drop_objection(this);
	endtask : run_phase

endclass : alu_underflow_test
