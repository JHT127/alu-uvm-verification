

// alu undefined opcode sequence ===========================================


class alu_undefined_opcode_sequence extends uvm_sequence #(alu_sequence_item);


	// Declaring ------------------------------
		virtual alu_interface vif;


	// utility macro ----------------------------------------
	`uvm_object_utils(alu_undefined_opcode_sequence)



	// constructor ----------------------------------------
	function new(string name = "alu_undefined_opcode_sequence");
		super.new(name);
	endfunction : new



	// body ----------------------------------------
	task body();
  
		alu_sequence_item req;


		if (!uvm_config_db #(virtual alu_interface)::get(null, "", "vif", vif))
			`uvm_fatal(get_type_name(), "vif not set at top level")



		// reset the dut
		req = alu_sequence_item::type_id::create("req");
		start_item(req);
		if (!req.randomize() with { rst == 1; })
			`uvm_error(get_type_name(), "randomization failed")
		`uvm_info(get_type_name(), "resetting the dut", UVM_NONE)
		finish_item(req);
		@(posedge vif.clk);



		// drive a reserved / unsupported opcode
		req = alu_sequence_item::type_id::create("req");
		start_item(req);
		if (!req.randomize() with { rst == 0; Opcode inside {3'b101, 3'b110, 3'b111}; })
			`uvm_error(get_type_name(), "randomization failed")
		finish_item(req);
		@(posedge vif.clk);
    
    
	endtask : body



endclass : alu_undefined_opcode_sequence
