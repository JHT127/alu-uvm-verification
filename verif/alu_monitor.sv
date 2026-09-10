

// alu monitor ===========================================


class alu_monitor extends uvm_monitor;



	// Declaring ------------------------------
		virtual alu_interface vif;
		uvm_analysis_port #(alu_sequence_item) port;
		alu_sequence_item last_item;



	// utility macro ----------------------------------------
		`uvm_component_utils(alu_monitor)



	// constructor ----------------------------------------
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new




	// build phase ----------------------------------------
	function void build_phase(uvm_phase phase);
  
		super.build_phase(phase);
		port = new("port", this);
		if (!uvm_config_db #(virtual alu_interface)::get(this, "", "vif", vif))
			`uvm_fatal(get_type_name(), "vif not set at top level")
      
	endfunction : build_phase




	// run phase ----------------------------------------
	task run_phase(uvm_phase phase);
		alu_sequence_item item;

		`uvm_info(get_type_name(), "inside run_phase", UVM_HIGH)

		forever begin
			item = alu_sequence_item::type_id::create("item");

			// Sample after the rising edge so the registered DUT outputs have updated.
			@(posedge vif.clk);
			#1step;
			if (vif.rst)
				continue;

			item.A      = vif.A;
			item.B      = vif.B;
			item.Opcode = vif.Opcode;
			item.Result = vif.Result;
			item.Error  = vif.Error;

			if (last_item != null &&
				item.A === last_item.A &&
				item.B === last_item.B &&
				item.Opcode === last_item.Opcode &&
				item.Result === last_item.Result &&
				item.Error === last_item.Error)
				continue;

			last_item = item;
			port.write(item);
		end

	endtask : run_phase




endclass : alu_monitor