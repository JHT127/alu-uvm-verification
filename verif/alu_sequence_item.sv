

// alu sequence item ===========================================


class alu_sequence_item extends uvm_sequence_item;


	// Declaring ------------------------------
  
		// control signal
		rand logic rst;
    
		// operands
		rand logic signed [31:0] A;      // operand 1
		rand logic        [31:0] B;      // operand 2
    
		// opcode
		rand logic        [2:0]  Opcode; // operation select

		// dut outputs
		logic [31:0] Result;             // result
		logic        Error;              // error flag



	// utility and field macros ----------------------------------------
		`uvm_object_utils_begin(alu_sequence_item)
			`uvm_field_int(rst,    UVM_ALL_ON)
			`uvm_field_int(A,      UVM_ALL_ON)
			`uvm_field_int(B,      UVM_ALL_ON)
			`uvm_field_int(Opcode, UVM_ALL_ON)
			`uvm_field_int(Result, UVM_ALL_ON)
			`uvm_field_int(Error,  UVM_ALL_ON)
		`uvm_object_utils_end



	// constructor ----------------------------------------
	function new(string name = "alu_sequence_item");
		super.new(name);
	endfunction : new



endclass : alu_sequence_item