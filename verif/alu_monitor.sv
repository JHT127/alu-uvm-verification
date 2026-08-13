

// alu monitor ===========================================


class alu_monitor extends uvm_monitor;



	// Declaring ------------------------------
		virtual alu_interface vif;
		uvm_analysis_port #(alu_sequence_item) port;



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

			wait (!vif.rst);

			// sample inputs
			@(vif.cb_mon);
			item.A      = vif.cb_mon.A;
			item.B      = vif.cb_mon.B;
			item.Opcode = vif.cb_mon.Opcode;

			// sample outputs (one cycle later, once the DUT has reacted)
			@(vif.cb_mon);
			item.Result = vif.cb_mon.Result;
			item.Error  = vif.cb_mon.Error;

			// send transaction to the scoreboard
			port.write(item);
      
		end
    
	endtask : run_phase




endclass : alu_monitor