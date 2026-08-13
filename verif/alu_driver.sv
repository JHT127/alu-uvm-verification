

// alu driver ===========================================


class alu_driver extends uvm_driver #(alu_sequence_item);



	// Declaring ------------------------------
		virtual alu_interface vif;



	// utility macro ----------------------------------------
		`uvm_component_utils(alu_driver)



	// constructor ----------------------------------------
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new



	// build phase ----------------------------------------
	function void build_phase(uvm_phase phase);
  
		super.build_phase(phase);
		if (!uvm_config_db #(virtual alu_interface)::get(this, "", "vif", vif))
			`uvm_fatal(get_type_name(), "vif not set at top level")
      
	endfunction : build_phase




	// run phase ----------------------------------------
	task run_phase(uvm_phase phase);
  
		alu_sequence_item item;
    
		forever begin
    
			seq_item_port.get_next_item(item);
			drive(item);
      
			`uvm_info(get_type_name(), $sformatf("driven to DUT: rst=%0b A=%0d B=%0d Opcode=%h",
			          item.rst, item.A, item.B, item.Opcode), UVM_HIGH)
                
			seq_item_port.item_done();
      
		end
    
	endtask : run_phase




	// drive task ----------------------------------------
	task drive(alu_sequence_item req);
		@(vif.cb_drv);
		vif.cb_drv.rst    <= req.rst;
		vif.cb_drv.A      <= req.A;
		vif.cb_drv.B      <= req.B;
		vif.cb_drv.Opcode <= req.Opcode;
	endtask : drive




endclass : alu_driver