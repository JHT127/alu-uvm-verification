

// alu agent ===========================================


class alu_agent extends uvm_agent;


	// Declaring ------------------------------
		alu_driver    driver;
		alu_sequencer sequencer;
		alu_monitor   monitor;



	// utility macro ----------------------------------------
		`uvm_component_utils(alu_agent)



	// constructor ----------------------------------------
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new



	// build phase ----------------------------------------
	function void build_phase(uvm_phase phase);
  
		super.build_phase(phase);
    
		if (get_is_active() == UVM_ACTIVE) begin
			sequencer = alu_sequencer::type_id::create("sequencer", this);
			driver    = alu_driver::type_id::create("driver", this);
		end
    
		monitor = alu_monitor::type_id::create("monitor", this);
    
	endfunction : build_phase




	// connect phase ----------------------------------------
	function void connect_phase(uvm_phase phase);
  
		super.connect_phase(phase);
    
		if (get_is_active() == UVM_ACTIVE) begin
			driver.seq_item_port.connect(sequencer.seq_item_export);
		end
    
	endfunction : connect_phase




endclass : alu_agent