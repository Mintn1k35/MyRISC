module ALU(
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [5:0] ex_type,
    output reg [31:0] result 
);

    always @(*) begin
        case(ex_type) 
            6'd0: result = operand1 + operand2; // add
            6'd1: result = operand1 + operand2; // addi
            6'd2: result = operand1 - operand2; // sub
            6'd3: result = operand1 & operand2; // and
            6'd4: result = operand1 & operand2; // andi
            6'd5: result = operand1 | operand2; // or
            6'd6: result = operand1 | operand2; // ori
            6'd7: result = operand1 ^ operand2; // xor
            6'd8: result = operand1 ^ operand2; // xori
            6'd9: result = operand1 << operand2; // sll
            6'd10: result = operand1 << operand2; // slli
            6'd11: result = operand1 >> operand2; // srl
            6'd12: result = operand1 >> operand2; // srli
            6'd13: result = $signed(operand1) >>> operand2; // sra
            6'd14: result = $signed(operand1) >>> operand2; // srai
            6'd15: result = ($signed(operand1) < $signed(operand2)) ? 32'd1 : 32'd0; //slt
            6'd16: result = ($signed(operand1) < $signed(operand2)) ? 32'd1 : 32'd0; //slti
            6'd17: result = (operand1 < operand2) ? 32'd1 : 32'd0; // sltu
            6'd18: result = (operand1 < operand2) ? 32'd1 : 32'd0; // sltiu
            6'd19: result = operand2;
            6'd20: result = operand1 + operand2;
            default:  result = 32'd0;
        endcase	
	end
endmodule