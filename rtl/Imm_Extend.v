
module Imm_Extend(
	// Input signals
	input wire [31:0] instr,
	// Output signals	
	output reg [31:0] imm_extend
);

	wire [6:0] opcode = instr[6:0];

    always @(*) begin
        casex(opcode) // check i_opcode
            7'b0000011: imm_extend = { {20{instr[31]}} , instr[31:20] };                                        // LW
            7'b0100011: imm_extend = { {20{instr[31]}} , instr[31:25] , instr[11:7] };                          // SW
            7'b1101111: imm_extend = { {12{instr[31]}} , instr[19:12] , instr[20] , instr[30:21] , 1'b0 };      // JAL
            7'b1100111: imm_extend = { {20{instr[31]}} , instr[31:20] };                                        // JALR
            7'b1100011: imm_extend = { {20{instr[31]}} , instr[7] , instr[30:25] , instr[11:8] , {1{1'b0}} };   // Branch
            7'b0110111: imm_extend = { instr[31:12], {12'b000000000000} };                                      // lui
            7'b0010011: 
            begin
                if((instr[14:12] == 3'b001) | (instr[14:12] == 3'b101))                                     // slli/srli/srlai
                        imm_extend <= { {27'b0} , instr[24:20] };
                else 
                    imm_extend <= { {20{instr[31]}} , instr[31:20] };                                            // ADDI/ANDI/ORI/XORI                                            
            end
            7'b0010111: imm_extend <= {instr[31:12], 12'd0}; // auipc
            default: imm_extend <= 32'bx;
        endcase
    end
endmodule





