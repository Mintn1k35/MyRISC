
module Branch_Excute(
	// Input signals
	input wire [31:0] instr,
	input wire [31:0] imm_ex,
	input wire [31:0] rs1_data,
	input wire [31:0] rs2_data,	
	input wire [31:0] pc_addr,
	input wire [1:0] data1_depend,
	input wire [1:0] data2_depend,
	// Output signals	
	output wire j_accept,
	output wire j_wait,
	output reg [31:0] j_addr
);

	wire [6:0] opcode = instr[6:0];
	wire [6:0] funct3 = instr[14:12];
	wire jal = (opcode == 7'b1101111);
	wire jalr = (opcode == 7'b1100111);
	reg jcond_accept;
	reg jncond_accept;
	reg [2:0] j_cond; 
	wire rs1_valid = (data1_depend == 2'b00);
	wire rs2_valid = (data2_depend == 2'b00);
	wire [31:0] pc_4 = pc_addr + 32'd4;


	always @(*) begin
		if(opcode == 7'b1100011) begin
			case(funct3)
				3'd0: j_cond = 3'b001; // beq
				3'd1: j_cond = 3'b010; // bne
				3'd4: j_cond = 3'b011; // blt
				3'd5: j_cond = 3'b100; // bge
				3'd6: j_cond = 3'b101; // bltu
				3'd7: j_cond = 3'b110; // bgeu
				default: j_cond = 3'b000;
			endcase
		end
		else begin
			j_cond = 3'b000;
		end
	end

	always @(*) begin
		case({j_cond, jalr, jal})
			5'b00001: begin
				jncond_accept = 1'b1;
				j_addr = pc_addr + imm_ex;
			end 
			5'b00010: begin
				jncond_accept = rs1_valid;
				j_addr = rs1_data + imm_ex;
			end 
			5'b00100: begin
				jcond_accept = (rs1_data == rs2_data) & (rs1_valid & rs2_valid);
				j_addr = pc_addr + imm_ex;
			end
			5'b01000: begin
				jcond_accept = (rs1_data != rs2_data) & (rs1_valid & rs2_valid);
				j_addr = pc_addr + imm_ex;
			end
			5'b01100: begin
				jcond_accept = ($signed(rs1_data) < $signed(rs2_data)) & (rs1_valid & rs2_valid);
				j_addr = pc_addr + imm_ex;
			end
			5'b10000: begin
				jcond_accept = ($signed(rs1_data) >= $signed(rs2_data)) & (rs1_valid & rs2_valid);
				j_addr = pc_addr + imm_ex;
			end
			5'b10100: begin
				jcond_accept = (rs1_data < rs2_data) & (rs1_valid & rs2_valid);
				j_addr = pc_addr + imm_ex;
			end
			5'b11000: begin
				jcond_accept = (rs1_data < rs2_data) & (rs1_valid & rs2_valid);
				j_addr = pc_addr + imm_ex;
			end
			default: begin
				jncond_accept = 1'b0;
				jcond_accept = 1'b0;
				j_addr = 32'd0;
			end
		endcase
	end

	assign j_accept = jncond_accept | jcond_accept;
	assign j_wait = ((j_cond != 3'b000) & !rs1_valid) | ((j_cond != 3'b000) & !rs2_valid) | (jalr & !rs1_valid);

endmodule





