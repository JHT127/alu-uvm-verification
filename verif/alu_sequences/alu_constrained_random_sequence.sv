// alu constrained-random sequence ===========================================


class alu_constrained_random_sequence extends uvm_sequence #(alu_sequence_item);


	// Declaring ------------------------------
		virtual alu_interface vif;
		int unsigned scenario_count = 100;


	// utility macro ----------------------------------------
	`uvm_object_utils(alu_constrained_random_sequence)


	// constructor ----------------------------------------
	function new(string name = "alu_constrained_random_sequence");
		super.new(name);
	endfunction : new


	// body ----------------------------------------
	task body();
		alu_sequence_item reset_item;
		alu_sequence_item req;

		if (!uvm_config_db #(virtual alu_interface)::get(null, "", "vif", vif))
			`uvm_fatal(get_type_name(), "vif not set at top level")

		reset_item = alu_sequence_item::type_id::create("reset_item");
		start_item(reset_item);
		reset_item.rst = 1'b1;
		reset_item.A = '0;
		reset_item.B = '0;
		reset_item.Opcode = 3'b000;
		finish_item(reset_item);
		@(posedge vif.clk);

		// Legal operations: broad constrained-random exploration.
		repeat (scenario_count) begin
			req = alu_sequence_item::type_id::create("legal_req");
			start_item(req);
			if (!req.randomize() with {
				rst == 0;
				Opcode inside {[3'b000:3'b100]};
			})
				`uvm_fatal(get_type_name(), "legal-operation randomization failed")
			finish_item(req);
			@(posedge vif.clk);
		end

		// Reserved operations: every unsupported opcode is deliberately selected.
		repeat (scenario_count) begin
			req = alu_sequence_item::type_id::create("reserved_req");
			start_item(req);
			if (!req.randomize() with {
				rst == 0;
				Opcode inside {[3'b101:3'b111]};
			})
				`uvm_fatal(get_type_name(), "reserved-operation randomization failed")
			finish_item(req);
			@(posedge vif.clk);
		end

		// Addition overflow: same-sign operands with magnitudes that force overflow.
		repeat (scenario_count) begin
			req = alu_sequence_item::type_id::create("add_overflow_req");
			start_item(req);
			if (!req.randomize() with {
				rst == 0;
				Opcode == 3'b000;
				A inside {[32'sh40000000:32'sh7fffffff]};
				B inside {[32'h40000000:32'h7fffffff]};
			})
				`uvm_fatal(get_type_name(), "positive-add overflow randomization failed")
			finish_item(req);
			@(posedge vif.clk);

			req = alu_sequence_item::type_id::create("add_underflow_req");
			start_item(req);
			if (!req.randomize() with {
				rst == 0;
				Opcode == 3'b000;
				A inside {[32'sh80000000:-32'sh40000001]};
				B inside {[32'h80000000:32'hbfffffff]};
			})
				`uvm_fatal(get_type_name(), "negative-add overflow randomization failed")
			finish_item(req);
			@(posedge vif.clk);
		end

		// Subtraction overflow/underflow: opposite signs with forced magnitude.
		repeat (scenario_count) begin
			req = alu_sequence_item::type_id::create("sub_overflow_req");
			start_item(req);
			if (!req.randomize() with {
				rst == 0;
				Opcode == 3'b001;
				A inside {[32'sh40000001:32'sh7fffffff]};
				B inside {[32'h80000000:32'hc0000000]};
			})
				`uvm_fatal(get_type_name(), "positive-sub overflow randomization failed")
			finish_item(req);
			@(posedge vif.clk);

			req = alu_sequence_item::type_id::create("sub_underflow_req");
			start_item(req);
			if (!req.randomize() with {
				rst == 0;
				Opcode == 3'b001;
				A inside {[32'sh80000000:32'shc0000000]};
				B inside {[32'h40000001:32'h7fffffff]};
			})
				`uvm_fatal(get_type_name(), "negative-sub underflow randomization failed")
			finish_item(req);
			@(posedge vif.clk);
		end

		// Logical operations: random operands, but only legal logical opcodes.
		repeat (scenario_count) begin
			req = alu_sequence_item::type_id::create("logical_req");
			start_item(req);
			if (!req.randomize() with {
				rst == 0;
				Opcode inside {3'b010, 3'b011, 3'b100};
			})
				`uvm_fatal(get_type_name(), "logical-operation randomization failed")
			finish_item(req);
			@(posedge vif.clk);
		end

		// Safe arithmetic: bounded values that cannot overflow or underflow.
		repeat (scenario_count) begin
			req = alu_sequence_item::type_id::create("safe_arithmetic_req");
			start_item(req);
			if (!req.randomize() with {
				rst == 0;
				Opcode inside {3'b000, 3'b001};
				A inside {[-32'sd1000:32'sd1000]};
				B inside {[32'h00000000:32'h000003e8]};
			})
				`uvm_fatal(get_type_name(), "safe-arithmetic randomization failed")
			finish_item(req);
			@(posedge vif.clk);
		end
	endtask : body


endclass : alu_constrained_random_sequence
