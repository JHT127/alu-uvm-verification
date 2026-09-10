


// alu subscriber ===========================================



class alu_subscriber extends uvm_subscriber #(alu_sequence_item);



	// Declaring ------------------------------
		alu_sequence_item sub;



	// utility macro ----------------------------------------
		`uvm_component_utils(alu_subscriber)



	// covergroup ----------------------------------------
	covergroup aluCoverage;
		option.per_instance = 1;

		A: coverpoint sub.A {
			bins minimum = {32'sh80000000};
			bins maximum = {32'sh7fffffff};
			bins zero    = {32'sh00000000};
			bins one     = {32'sh00000001};
			bins minus_one = {-32'sd1};
			bins other   = default;
		}

		B: coverpoint sub.B {
			bins one        = {32'h00000001};
			bins all_zero   = {32'h00000000};
			bins all_one    = {32'hffffffff};
			bins alternating_a = {32'haaaaaaaa};
			bins alternating_5 = {32'h55555555};
			bins other      = default;
		}

		Opcode: coverpoint sub.Opcode {
			bins add        = {3'b000};
			bins subtract   = {3'b001};
			bins and_op     = {3'b010};
			bins or_op      = {3'b011};
			bins xor_op     = {3'b100};
			bins reserved   = {[3'b101:3'b111]};
		}

		Result: coverpoint sub.Result {
			bins zero       = {32'h00000000};
			bins minimum    = {32'h80000000};
			bins maximum    = {32'h7fffffff};
			bins all_zero   = {32'h00000000};
			bins all_one    = {32'hffffffff};
			bins other      = default;
		}

		Error: coverpoint sub.Error {
			bins clear = {1'b0};
			bins set   = {1'b1};
		}

		A_sign: coverpoint sub.A[31] {
			bins positive = {1'b0};
			bins negative = {1'b1};
		}

		B_sign: coverpoint sub.B[31] {
			bins positive = {1'b0};
			bins negative = {1'b1};
		}

		operation_error: cross Opcode, Error {
			ignore_bins reserved_clear = binsof(Opcode.reserved) &&
			                             binsof(Error.clear);
			ignore_bins logical_set = binsof(Opcode) intersect
			                           {3'b010, 3'b011, 3'b100} &&
			                           binsof(Error.set);
		}
		operation_operand_sign: cross Opcode, A_sign, B_sign;
		logical_patterns: cross Opcode, B;
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