// alu.sv
// -----------------------------------------------------------------------------
// NOTE TO SELF (delete this comment block before publishing):
// This DUT was provided as part of the Orion VLSI internship. Before making
// this repo public, confirm with your instructor/supervisor whether the DUT
// source itself is okay to share publicly, separately from the lab documents.
// If not, consider re-implementing an equivalent ALU from scratch in your own
// words/style, or keeping this folder private and only publishing the tb/.
// -----------------------------------------------------------------------------

module alu (
    input  logic             clk,
    input  logic             rst,
    input  logic signed [31:0] A,   // operand 1
    input  logic        [31:0] B,   // operand 2
    input  logic        [2:0]  Opcode,
    output logic        [31:0] Result,
    output logic               Error
);

    // TODO: paste/adapt DUT implementation here once sharing is confirmed.

endmodule
