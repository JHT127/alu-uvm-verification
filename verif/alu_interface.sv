

// alu dut interface ===========================================


interface alu_interface (input logic clk);



	// Declaring ------------------------------
		// alu inputs
    logic  rst;
		logic signed [31:0] A;      // operand 1
		logic        [31:0] B;      // operand 2
		logic        [2:0]  Opcode; // operation select
		// alu outputs
		logic        [31:0] Result; // result
		logic   Error;  // error flag




	// clocking blocks ----------------------------------------
  
  
		// -----driver clocking block------
		clocking cb_drv @(negedge clk);

			default input #1 output #0;

			// outputs driven by the driver
			output rst;
			output A;
			output B;
			output Opcode;
      
		endclocking : cb_drv



		// -------monitor clocking block---------------
		clocking cb_mon @(posedge clk);
    
			default input #0 output #1;
      
			// inputs sampled by the monitor
			input A;
			input B;
			input Opcode;
			input Result;
			input Error;
      
		endclocking : cb_mon




	// modports ----------------------------------------
	modport drv (clocking cb_drv, input clk);
	modport mon (clocking cb_mon, input clk);



endinterface : alu_interface