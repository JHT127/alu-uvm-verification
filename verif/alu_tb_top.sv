


// alu testbench top ===========================================


`include "uvm_macros.svh"

import uvm_pkg::*;
import alu_pkg::*;



module alu_tb_top;


	// Declaring ------------------------------
		logic clk;
		logic rst;



	// clock generation ----------------------------------------
	always #5 clk <= ~clk;



	initial begin
		clk = 0;
	end



	// interface instance ----------------------------------------
	alu_interface intf (clk);



	// dut instance ----------------------------------------
	alu dut (
		.clk(clk),
		.rst(intf.rst),
		.A(intf.A),
		.B(intf.B),
		.Opcode(intf.Opcode),
		.Result(intf.Result),
		.Error(intf.Error)
	);



	// publish the interface to the uvm environment ----------------------------------------
	initial begin
		uvm_config_db #(virtual alu_interface)::set(uvm_root::get(), "*", "vif", intf);
	end



	// waveform dumping ----------------------------------------
	initial begin
		$shm_open("waves.shm");
		$shm_probe(alu_tb_top, "AS");
	end



	// run the test ----------------------------------------
	initial begin
		run_test("alu_random_test");
	end
  
  


endmodule : alu_tb_top