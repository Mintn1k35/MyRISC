module LSU(
    // Inputs
    input wire [5:0] ex_type,
    input wire [31:0] data,
    input wire [31:0] dcache_data,
    // Outputs
    output reg [31:0] write_data,
    output reg [31:0] result_wb
);
    // Resolve lw result
    always @(*) begin
		case(ex_type)
			6'd21: begin
				result_wb = {dcache_data[31], 23'd0, dcache_data[7:0]};
			end
			6'd22: begin
				result_wb = {dcache_data[31], 15'd0, dcache_data[15:0]};
			end
			6'd23: begin
				result_wb = dcache_data;
			end
			6'd24: begin
				result_wb = {24'd0, dcache_data[7:0]};
			end
			6'd25: begin
				result_wb = {16'd0, dcache_data[15:0]};
			end
			default: begin
				result_wb = 32'd0;
			end
		endcase
    end

    // Resolve sw 
    always @(*) begin
		case(ex_type)
			6'd26: begin
				write_data = {24'd0, data[7:0]};
			end
			6'd27: begin
				write_data = {16'd0, data[15:0]};
			end
			6'd28: begin
				write_data = data;
			end
			default: begin
				write_data = 32'd0;
			end
		endcase
	end

endmodule