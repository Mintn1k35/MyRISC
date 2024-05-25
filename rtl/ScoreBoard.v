module ScoreBoard(
    input wire clk,
    input wire rst_n,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire alu,
    input wire mul,
    input wire lsu,
    input wire [1:0] alu_state, 
    input wire [1:0] mul_state,
    input wire [1:0] lsu_state,
    input wire alu_done,
    input wire mul_done,
    input wire lsu_done,
    input wire [4:0] rd_alu_update,
    input wire [4:0] rd_mul_update,
    input wire [4:0] rd_lsu_update,
	input wire store_mem,
    output wire stop_fetch,
    output wire alu_load,
    output wire mul_load,
    output wire lsu_load,
    output wire [1:0] data1_depend,
    output wire [1:0] data2_depend
);

    reg [1:0] register_status[0:31];
    wire same_rd = (register_status[rd] != 2'b00) & !store_mem; 

    always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			register_status[0] <= 2'b00;
			register_status[1] <= 2'b00;
			register_status[2] <= 2'b00;
			register_status[3] <= 2'b00;
			register_status[4] <= 2'b00;
			register_status[5] <= 2'b00;
			register_status[6] <= 2'b00;
			register_status[7] <= 2'b00;
			register_status[8] <= 2'b00;
			register_status[9] <= 2'b00;
			register_status[10] <= 2'b00;
			register_status[11] <= 2'b00;
			register_status[12] <= 2'b00;
			register_status[13] <= 2'b00;
			register_status[14] <= 2'b00;
			register_status[15] <= 2'b00;
			register_status[16] <= 2'b00;
			register_status[17] <= 2'b00;
			register_status[18] <= 2'b00;
			register_status[19] <= 2'b00;
			register_status[20] <= 2'b00;
			register_status[21] <= 2'b00;
			register_status[22] <= 2'b00;
			register_status[23] <= 2'b00;
			register_status[24] <= 2'b00;
			register_status[25] <= 2'b00;
			register_status[26] <= 2'b00;
			register_status[27] <= 2'b00;
			register_status[28] <= 2'b00;
			register_status[29] <= 2'b00;
			register_status[30] <= 2'b00;
            register_status[31] <= 2'b00;
		end
		else begin
			// Update for ALU
			if((alu_state == 2'b00) & alu) register_status[rd] <= 2'b01;

			if(alu_done) register_status[rd_alu_update] <= 2'b00; 

			// Update for MUl
			if((mul_state == 2'b00) & mul) register_status[rd] <= 2'b10;

			if(mul_done) register_status[rd_mul_update] <= 2'b00;

			// Update for LSU
			if((lsu_state == 2'b00) & lsu & (!store_mem)) register_status[rd] <= 2'b11;

			if(lsu_done) register_status[rd_lsu_update] <= 2'b00; 
		end
	end

    assign stop_fetch = ((alu_state != 2'b00) & alu) | ((mul_state != 2'b00) & mul) | ((lsu_state != 2'b00) & lsu) | same_rd;
    
    assign data1_depend = register_status[rs1];
	assign data2_depend = register_status[rs2];
	assign alu_load = !stop_fetch & alu;
	assign mul_load = !stop_fetch & mul;
	assign lsu_load = !stop_fetch & lsu;
endmodule