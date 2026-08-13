

// alu random test ===========================================


class alu_random_test extends uvm_test;


	// Declaring ------------------------------
		alu_environment      env;
		alu_random_sequence  seq;



	// utility macro ----------------------------------------
		`uvm_component_utils(alu_random_test)



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
  
		phase.raise_objection(this);

		repeat (500) begin
			seq = alu_random_sequence::type_id::create("seq");
			seq.start(env.agent.sequencer);
		end

		phase.drop_objection(this);
		`uvm_info(get_type_name(), "end of testcase", UVM_LOW)
    
	endtask : run_phase




endclass : alu_random_test