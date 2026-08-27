

// alu scoreboard ===========================================


class alu_scoreboard extends uvm_scoreboard;


	// Declaring ------------------------------
		uvm_analysis_imp #(alu_sequence_item, alu_scoreboard) exp;
		alu_sequence_item packetQueue [$];



	// utility macro ----------------------------------------
		`uvm_component_utils(alu_scoreboard)



	// constructor ----------------------------------------
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new



	// build phase ----------------------------------------
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		exp = new("exp", this);
	endfunction : build_phase



	// write function ----------------------------------------
	function void write(alu_sequence_item req);
		packetQueue.push_back(req);
	endfunction : write



	// run phase ----------------------------------------
	task run_phase(uvm_phase phase);
		alu_sequence_item packet;
		alu_sequence_item refPacket;

		forever begin
    
			wait (packetQueue.size() > 0);
			packet = packetQueue.pop_front();


			refPacket    = alu_sequence_item::type_id::create("refPacket");
			refPacket.A      = packet.A;
			refPacket.B      = packet.B;
			refPacket.Opcode = packet.Opcode;


			alu_rf(packet.A, packet.B, packet.Opcode,
			       refPacket.Result, refPacket.Error);


			if (is_equal(refPacket, packet)) begin
				`uvm_info("PASS", $sformatf(
					"match :: A=%0d B=%0d Opcode=%h -> Result=%0d Error=%0b",
					packet.A, packet.B, packet.Opcode, packet.Result, packet.Error), UVM_LOW)
			end
      
			else begin
				`uvm_error("FAIL", $sformatf(
          "mismatch :: A=%0d B=%0d Opcode=%h | dut: Result=%0d Error=%0b | expected: Result=%0d Error=%0b",
          packet.A, packet.B, packet.Opcode,
          packet.Result, packet.Error,
          refPacket.Result, refPacket.Error))
			end
      
		end
    
	endtask : run_phase




	// is_equal function ----------------------------------------
	function bit is_equal(alu_sequence_item reference, alu_sequence_item packet);
		if (reference.A      === packet.A &&
		    reference.B      === packet.B &&
		    reference.Opcode === packet.Opcode &&
		    reference.Result === packet.Result &&
		    reference.Error  === packet.Error)
			return 1;
		else
			return 0;
	endfunction : is_equal




	// reference model ----------------------------------------
	static task alu_rf(input  logic signed [31:0] A,
	                    input  logic        [31:0] B,
	                    input  logic        [2:0]  Opcode,
	                    output logic        [31:0] Result,
	                    output logic               Error);
		Error = 0;
    
    
		case (Opcode)
    
    
			3'b000: begin
				// addition
				Result = A + B;
				if ((A > 0 && B > 0 && $signed(Result) < 0) ||
			    (A < 0 && B < 0 && $signed(Result) > 0))
					Error = 1;
			end


			3'b001: begin
				// subtraction (A - B)
				Result = A - B;
				if ((A < 0 && B > 0 && $signed(Result) > A) ||
			    (A > 0 && B < 0 && $signed(Result) < A))
					Error = 1;
			end


			3'b010: begin
				// bitwise and
				Result = A & B;
			end


			3'b011: begin
				// bitwise or
				Result = A | B;
			end


			3'b100: begin
				// bitwise xor
				Result = A ^ B;
			end


			default: begin
				// unsupported opcode
				Result = 0;
				Error  = 1'b1;
			end
      
		endcase
    
    
	endtask : alu_rf



endclass : alu_scoreboard