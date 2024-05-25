module ICache_Controller(
	// Input signals
	input wire clk,
	input wire rst_n,
	input wire stop,
	input wire stop_fetch,
	input wire rvalid,
	input wire rlast,
	input wire [31:0] rdata,
	input wire arready,
	input wire ecall,
	input wire j_accept,
	input wire [31:0] j_addr,
	input wire cache_rst_done,
	// Output signals	
	output reg rready,
	output reg [31:0] araddr,
	output reg 	arvalid,
	output wire [1:0] arburst,
	output wire [3:0] arcache,
	output wire [2:0] arsize,
	output wire [7:0] arlen,
	output wire [63:0] fetch_instr_pc
);

	wire stall = !arready | stop;

	// Controller State  00 - transfer addr, 01 - Cache received addr, 10 - enable rready, 11 - received data

	reg [1:0] control_state;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			araddr <= 32'd0;
		end
		else begin
			if(control_state == 2'b10) begin
				if(j_accept) araddr <= j_addr;
				else if(stop) araddr <= araddr;
				else if (stop_fetch) araddr <= araddr - 32'd4;
				else if (ecall) araddr <= 32'd200;
			end
			else begin
				if(!arready) araddr <= araddr;
				else araddr <= araddr + 32'd4;
			end
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			control_state <= 2'b00;
//			araddr <= 32'd0;
		end
		else begin
			case(control_state)
				2'b00: begin
					if(arready) begin
						control_state <= 2'b01;
					end
					else begin
						control_state <= control_state;
					end
					// araddr <= araddr;
				end

				2'b01: begin
					control_state <= 2'b10;
					// araddr <= araddr;
				end

				2'b10: begin
					if(rvalid & rlast) begin
						control_state <= 2'b11;
					end
					else begin
						control_state <= control_state;
					end
					// if(j_accept) araddr <= 1'b0
				end

				2'b11: begin
					control_state <= 2'b00;
				end
			endcase
		end
	end

	always @(*) begin
		case(control_state)
			2'b00: begin
				arvalid = (!cache_rst_done) ? 1'b1 : 1'b0;
				rready = 1'b0;
			end
			2'b01: begin
				arvalid = 1'b0;
				rready = 1'b0;
			end	
			2'b10: begin
				rready = 1'b1;
				arvalid = 1'b0;
			end
			2'b11: begin
				rready = 1'b0;
				arvalid = 1'b0;
			end
		endcase
	end

	assign arburst = 2'b01;
	assign arsize = 3'd2;
	assign arlen = 8'd0;
	assign arcache = 4'd7;
	assign fetch_instr_pc = (rlast & rvalid) ? {araddr - 32'd4, rdata} : 64'd0;

endmodule