// alu coverage sequence ===========================================


class alu_coverage_sequence extends uvm_sequence #(alu_sequence_item);


	// Declaring ------------------------------
		virtual alu_interface vif;


	// utility macro ----------------------------------------
	`uvm_object_utils(alu_coverage_sequence)


	// constructor ----------------------------------------
	function new(string name = "alu_coverage_sequence");
		super.new(name);
	endfunction : new


	// body ----------------------------------------
	task body();
		alu_sequence_item reset_item;

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

		// Arithmetic boundaries, signed values, and zero/one operands.
		send(32'sh00000000, 32'h00000000, 3'b000);
		send(32'sh7fffffff, 32'h00000000, 3'b000);
		send(32'sh80000000, 32'h00000000, 3'b001);
		send(32'sh00000001, 32'hffffffff, 3'b001);
		send(32'shffffffff, 32'h00000001, 3'b000);
		send(32'sh7fffffff, 32'h00000001, 3'b000);
		send(32'sh80000000, 32'h00000001, 3'b001);

		// Logical operations with the specified pattern pairs.
		send(32'haaaaaaaa, 32'h55555555, 3'b010);
		send(32'haaaaaaaa, 32'h55555555, 3'b011);
		send(32'haaaaaaaa, 32'h55555555, 3'b100);
		send(32'hffffffff, 32'h00000000, 3'b010);
		send(32'hffffffff, 32'h00000000, 3'b011);
		send(32'hffffffff, 32'h00000000, 3'b100);
		send(32'h00000000, 32'hffffffff, 3'b010);
		send(32'h00000000, 32'hffffffff, 3'b011);
		send(32'h00000000, 32'hffffffff, 3'b100);

		// Every reserved opcode must set Error.
		send(32'h00000000, 32'h00000000, 3'b101);
		send(32'h00000001, 32'hffffffff, 3'b110);
		send(32'hffffffff, 32'h00000000, 3'b111);

		// Close operation/pattern and operation/sign cross coverage.
		for (int opcode = 0; opcode < 8; opcode++) begin
			for (int pattern = 0; pattern < 6; pattern++) begin
				case (pattern)
					0: send(32'sh00000000, 32'h00000000, opcode[2:0]);
					1: send(32'sh00000001, 32'h00000001, opcode[2:0]);
					2: send(32'sh00000001, 32'hffffffff, opcode[2:0]);
					3: send(32'sh00000001, 32'haaaaaaaa, opcode[2:0]);
					4: send(32'sh00000001, 32'h55555555, opcode[2:0]);
					5: send(32'sh00000001, 32'h12345678, opcode[2:0]);
				endcase
			end

			send(32'sh00000001, 32'h00000001, opcode[2:0]);
			send(-32'sd1, 32'h80000000, opcode[2:0]);
			send(32'sh00000001, 32'h80000000, opcode[2:0]);
			send(-32'sd1, 32'h00000001, opcode[2:0]);
		end
	endtask : body


	// drive one operation and wait for its registered result
	task send(input logic signed [31:0] a,
	          input logic [31:0] b,
	          input logic [2:0] opcode);
		alu_sequence_item req;

		req = alu_sequence_item::type_id::create("req");
		start_item(req);
		req.rst = 1'b0;
		req.A = a;
		req.B = b;
		req.Opcode = opcode;
		finish_item(req);
		@(posedge vif.clk);
	endtask : send


endclass : alu_coverage_sequence
