

// alu sequencer ===========================================


class alu_sequencer extends uvm_sequencer #(alu_sequence_item);


	// utility macro ----------------------------------------
		`uvm_component_utils(alu_sequencer)


	// constructor ----------------------------------------
	function new(string name = "alu_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction : new


endclass : alu_sequencer