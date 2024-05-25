module DCache_Controller(
	// Input signals
	input wire clk,
	input wire rst_n,
	input wire read_mem,
	input wire write_mem,
	input wire [31:0] addr,
	input wire addr_valid,
	input wire [31:0] write_data,
	input wire write_data_valid,
	input wire cache_rst_done,
	// AW channel
	input wire awready,
	output wire [31:0] awaddr,
	output wire [1:0] awburst,
	output wire [3:0] awcache,
	output wire [7:0] awlen,
	output wire [2:0] awsize,
	output reg awvalid,
	// W channel
	input wire wready,
	output wire [31:0] wdata,
	output reg wlast,
	output reg [3:0] wstrb,
	output reg wvalid,
	// B channel
	input wire [1:0] bresp,
	input wire bvalid,
	output reg bready,
	// AR channel
	input wire arready,
	output wire [31:0] araddr,
	output wire [1:0] arburst,
	output wire [3:0] arcache,
	output wire [7:0] arlen,
	output wire [2:0] arsize,
	output reg arvalid,
	// R channel
	input wire [31:0] rdata,
	input wire rlast,
	input wire rvalid,
	output reg rready,
	// Output signals
	output wire mem_done,
	output wire [31:0] result
);

	reg [1:0] write_state = 2'b00; 	
    reg [1:0] pre_state, pre_state1;
    reg [1:0] read_state = 2'b00;

	assign awaddr = addr;
	assign wdata = write_data;
	assign araddr = addr;
	assign result = rdata;
	assign awburst = (rst_n & write_mem) ? 2'b00 : 2'bz;
	assign awlen = (rst_n & write_mem) ? 8'd0 : 8'bz;
	assign awcache = (rst_n & write_mem) ? 4'd11 : 4'bz;
	assign awsize = (rst_n & write_mem) ? 3'd2 : 3'bz;
	assign arburst = (rst_n & !write_mem) ? 2'b00 : 2'bz;
	assign arlen = (rst_n & !write_mem) ? 8'd0 : 8'bz;
	assign arcache = (rst_n & !write_mem) ? 4'd7 : 4'bz;
	assign arsize = (rst_n & !write_mem) ? 3'd2 : 3'bz;
	
	always @(posedge clk)
	begin
		if (!rst_n)
			begin
				arvalid = 1'b0;
				awvalid = 1'b0;
				rready = 1'b0;
				wvalid = 1'b0;
			end
		else begin
			if (write_mem)
			begin
			    case(write_state)
			    2'b00: begin
			         if (pre_state == 2'b11) awvalid = 1'b0;
			         else awvalid = addr_valid;
			         pre_state=2'b00;
			         if (awready) begin awvalid = 1'b0; write_state = 2'b01; end
			    end
			    2'b01: begin
			         wvalid = write_data_valid;
			         wlast = 1'b1;
			         wstrb = 4'b1111;
			         pre_state = 2'b01;
			         if (wready) begin 
			             write_state = 2'b10;
			         end
			    end
			    2'b10: begin
			         wlast = 1'b0;
			         wstrb = 4'b0000;
			         wvalid = 1'b0;
			         bready = 1'b1;
			         pre_state = 2'b10;
			         if (bvalid) begin bready = 1'b0; write_state = 2'b11; end
			    end 
			    2'b11: begin
			         pre_state = 2'b11;
			         if (mem_done) write_state = 2'b00; 
			    end
			    endcase         
			end
			if (read_mem == 1'b1)
			begin
			    case(read_state)
			    2'b00: begin
			         if (pre_state1 == 2'b10) arvalid = 1'b0;
			         else arvalid = addr_valid;
			         pre_state1 = 2'b00;
			         if (arready) begin arvalid = 1'b0; read_state = 2'b01; end
			    end
			    2'b01: begin
			         rready = 1'b1;
			         if (rvalid) read_state = 2'b10;
			    end
			    2'b10: begin
			         pre_state1 = 2'b10;
			         rready = 1'b0;
			         if (mem_done) read_state = 2'b00;
			    end  
			    endcase
			end
		end
	end
	assign mem_done = ((rlast == 1'b1) | ((bvalid == 1'b1) & (bresp == 2'b00)));

	// parameter WRITE_IDLE = 2'b00;
	// parameter SET_ADDR = 2'b01;
	// parameter SET_DATA = 2'b10;
	// parameter WRITE_WAIT = 2'b11;
	// parameter READ_IDLE = 2'b00;
	// parameter SET_RADDR = 2'b01;
	// parameter READ_WAIT = 2'b10;
	// reg [1:0] write_state, read_state;

	// // Manage write state
	// always @(posedge clk or negedge rst_n) begin
	// 	if(!rst_n) begin
	// 		write_state <= WRITE_IDLE;
	// 	end
	// 	else begin
	// 			case(write_state)
	// 				WRITE_IDLE: begin
	// 					if(write_mem) write_state <= SET_ADDR;
	// 					else write_state <= write_state;
	// 				end
	// 				SET_ADDR: begin
	// 					if(awready & awvalid) write_state <= SET_DATA;
	// 					else write_state <= write_state;
	// 				end
	// 				SET_DATA: begin
	// 					if(wready & wvalid) write_state <= WRITE_WAIT;
	// 					else write_state <= write_state;
	// 				end
	// 				WRITE_WAIT: begin
	// 					if((bvalid == 1'b1) & (bresp == 2'b00)) write_state <= WRITE_IDLE;
	// 					else write_state <= write_state;
	// 				end
	// 				default: write_state <= WRITE_IDLE;
	// 			endcase
	// 	end
	// end


	// always @(posedge clk or negedge rst_n) begin
	// 	if(!rst_n) begin
	// 		read_state <= READ_IDLE;
	// 	end
	// 	else begin
	// 			case(read_state)
	// 				READ_IDLE: begin
	// 					if(read_mem) read_state <= SET_RADDR;
	// 					else read_state <= read_state;
	// 				end
	// 				SET_RADDR: begin
	// 					if(arready) read_state <= READ_WAIT;
	// 					else read_state <= read_state;
	// 				end
	// 				READ_WAIT: begin
	// 					if(rlast & rvalid) read_state <= READ_IDLE;
	// 					else read_state <= read_state;
	// 				end
	// 				default: begin
	// 					read_state <= READ_IDLE;
	// 				end
	// 			endcase
	// 	end
	// end

	// assign awaddr = addr;
	// assign wdata = write_data;
	// assign araddr = addr;
	// always @(*) begin
	// 	case(write_state)
	// 		WRITE_IDLE: begin
	// 			awvalid = 1'b0;
	// 			wvalid = 1'b0;
	// 			wlast = 1'b0;
	// 			wstrb = 4'd0;
	// 		end
	// 		SET_ADDR: begin
	// 			awvalid = addr_valid;
	// 			wvalid = 1'b0;
	// 			wlast = 1'b0;
	// 			wstrb = 4'd0;
	// 		end
	// 		SET_DATA: begin
	// 			awvalid = 1'b0;
	// 			wvalid = write_data_valid;
	// 			wlast = 1'b1;
	// 			wstrb = 4'hf;
	// 		end
	// 		WRITE_WAIT: begin
	// 			awvalid = 1'b0;
	// 			wvalid = 1'b0;
	// 			wlast = 1'b1;
	// 			wstrb = 4'hf;
	// 		end
	// 		default: begin
	// 			awvalid = 1'b0;
	// 			wvalid = 1'b0;
	// 			wlast = 1'b0;
	// 			wstrb = 4'd0;
	// 		end
	// 	endcase
	// 	case(read_state)
	// 		READ_IDLE: begin
	// 			arvalid = 1'b0;
	// 		end
	// 		SET_RADDR: begin
	// 			arvalid = addr_valid;
	// 		end
	// 		READ_WAIT: begin
	// 			arvalid = 1'b0;
	// 		end
	// 		default: begin
	// 			arvalid = 1'b0;
	// 		end
	// 	endcase
	// end
	// assign result = rdata;
	// assign awburst = (rst_n & write_mem) ? 2'b00 : 2'bz;
	// assign awlen = (rst_n & write_mem) ? 8'd0 : 8'bz;
	// assign awcache = (rst_n & write_mem) ? 4'd11 : 4'bz;
	// assign awsize = (rst_n & write_mem) ? 3'd2 : 3'bz;
	// assign arburst = (rst_n & read_mem) ? 2'b00 : 2'bz;
	// assign arlen = (rst_n & read_mem) ? 8'd0 : 8'bz;
	// assign arcache = (rst_n & read_mem) ? 4'd7 : 4'bz;
	// assign arsize = (rst_n & read_mem) ? 3'd2 : 3'bz;
	// assign rready = 1'b1;
	// assign bready = 1'b1;
	// assign mem_done = ((bresp == 2'b00) &  (bvalid == 1'b1)) | (rvalid & rlast);
endmodule