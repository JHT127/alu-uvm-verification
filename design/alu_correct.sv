module alu (
    input  logic               clk,
    input  logic               rst,
    input  logic signed [31:0] A,
    input  logic        [31:0] B,
    input  logic        [2:0]  Opcode,
    output logic        [31:0] Result,
    output logic               Error
);

    // Opcode encoding
    // 3'b000: Addition
    // 3'b001: Subtraction
    // 3'b010: AND
    // 3'b011: OR
    // 3'b100: XOR
    // 3'b101: Reserved
    // 3'b110: Reserved
    // 3'b111: Reserved

    always_ff @(posedge clk or posedge rst) begin
        logic signed [31:0] signed_b;

        if (rst) begin
            Result <= 32'b0;
            Error <= 1'b0;
        end
        else begin
            signed_b = $signed(B);
            Error = 1'b0;

            case (Opcode)
                3'b000: begin
                    Result = A + signed_b;
                    Error = (A[31] == signed_b[31]) &&
                            (Result[31] != A[31]);
                end

                3'b001: begin
                    Result = A - signed_b;
                    Error = (A[31] != signed_b[31]) &&
                            (Result[31] != A[31]);
                end

                3'b010: Result = A & B;
                3'b011: Result = A | B;
                3'b100: Result = A ^ B;

                default: begin
                    Result = 32'b0;
                    Error = 1'b1;
                end
            endcase
        end
    end

endmodule
