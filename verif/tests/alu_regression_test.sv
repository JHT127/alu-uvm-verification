

// alu regression test ===========================================


class alu_regression_test extends uvm_test;


	// Declaring ------------------------------
		alu_environment env;



	// utility macro ----------------------------------------
		`uvm_component_utils(alu_regression_test)



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
  
		alu_add_sequence               add_seq;
		alu_sub_sequence               sub_seq;
		alu_and_sequence               and_seq;
		alu_or_sequence                or_seq;
		alu_xor_sequence                xor_seq;
		alu_undefined_opcode_sequence  undef_seq;
		alu_overflow_sequence          ovf_seq;
		alu_underflow_sequence         udf_seq;

		phase.raise_objection(this);
phase.phase_done.set_drain_time(this, 30);

		add_seq = alu_add_sequence::type_id::create("add_seq");
		add_seq.start(env.agent.sequencer);

		sub_seq = alu_sub_sequence::type_id::create("sub_seq");
		sub_seq.start(env.agent.sequencer);

		and_seq = alu_and_sequence::type_id::create("and_seq");
		and_seq.start(env.agent.sequencer);

		or_seq = alu_or_sequence::type_id::create("or_seq");
		or_seq.start(env.agent.sequencer);

		xor_seq = alu_xor_sequence::type_id::create("xor_seq");
		xor_seq.start(env.agent.sequencer);

		undef_seq = alu_undefined_opcode_sequence::type_id::create("undef_seq");
		undef_seq.start(env.agent.sequencer);

		ovf_seq = alu_overflow_sequence::type_id::create("ovf_seq");
		ovf_seq.start(env.agent.sequencer);

		udf_seq = alu_underflow_sequence::type_id::create("udf_seq");
		udf_seq.start(env.agent.sequencer);

		phase.drop_objection(this);
		`uvm_info(get_type_name(), "end of regression testcase", UVM_LOW)
    
	endtask : run_phase



endclass : alu_regression_test