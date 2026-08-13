


// alu subscriber ===========================================



class alu_subscriber extends uvm_subscriber #(alu_sequence_item);



	// Declaring ------------------------------
		alu_sequence_item sub;



	// utility macro ----------------------------------------
		`uvm_component_utils(alu_subscriber)



	// covergroup ----------------------------------------
	covergroup aluCoverage;
		A:      coverpoint sub.A;
		B:      coverpoint sub.B;
		Opcode: coverpoint sub.Opcode;
		Result: coverpoint sub.Result;
		Error:  coverpoint sub.Error;
	endgroup : aluCoverage



	// constructor ----------------------------------------
	function new(string name, uvm_component parent);
		super.new(name, parent);
		sub         = new();
		aluCoverage = new();
	endfunction : new



	// write method ----------------------------------------
	virtual function void write(alu_sequence_item t);
		sub.A      = t.A;
		sub.B      = t.B;
		sub.Opcode = t.Opcode;
		sub.Result = t.Result;
		sub.Error  = t.Error;
		aluCoverage.sample();
	endfunction : write



	// report phase ----------------------------------------
	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(),
		          $sformatf("coverage: %0.2f%%", aluCoverage.get_coverage()),
		          UVM_HIGH)
	endfunction : report_phase



endclass : alu_subscriber