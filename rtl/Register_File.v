
module Register_File(
	// Input signals
	input wire clk,
	input wire rst_n,
	input wire [4:0] rs1,
	input wire [4:0] rs2,
	input wire [4:0] rd1,
	input wire [4:0] rd2, 
	input wire [4:0] rd3,
	input wire [31:0] write_data1,
	input wire [31:0] write_data2,
	input wire [31:0] write_data3,
	input wire write_en1,
	input wire write_en2,
	input wire write_en3,
	// Output signals	
	output wire [31:0] rs1_data,
	output wire [31:0] rs2_data
);

	reg [31:0] register[0:31];

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			register[0] <= 32'd0;
			register[1] <= 32'd0;
			register[2] <= 32'd0;
			register[3] <= 32'd0;
			register[4] <= 32'd0;
			register[5] <= 32'd0;
			register[6] <= 32'd0;
			register[7] <= 32'd0;
			register[8] <= 32'd0;
			register[9] <= 32'd0;
			register[10] <= 32'd0;
			register[11] <= 32'd0;
			register[12] <= 32'd0;
			register[13] <= 32'd0;
			register[14] <= 32'd0;
			register[15] <= 32'd0;
			register[16] <= 32'd0;
			register[17] <= 32'd0;
			register[18] <= 32'd0;
			register[19] <= 32'd0;
			register[20] <= 32'd0;
			register[21] <= 32'd0;
			register[22] <= 32'd0;
			register[23] <= 32'd0;
			register[24] <= 32'd0;
			register[25] <= 32'd0;
			register[26] <= 32'd0;
			register[27] <= 32'd0;
			register[28] <= 32'd0;
			register[29] <= 32'd0;
			register[30] <= 32'd0;
			register[31] <= 32'd0;
		end
		else begin
			if(write_en1 & (rd1 != 5'd0)) begin
				register[rd1] <= write_data1;
			end
			
			if(write_en2 & (rd2 != 5'd0)) begin
				register[rd2] <= write_data2;
			end

			if(write_en3 & (rd3 != 5'd0)) begin
				register[rd3] <= write_data3;
			end
		end
	end

	assign rs1_data = (rs1 == 5'd0) ? 32'd0 : register[rs1];
	assign rs2_data = (rs2 == 5'd0) ? 32'd0 : register[rs2];

endmodule





