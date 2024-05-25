module Issue_LSU(
    // Inputs
    input wire clk,
    input wire rst_n,
    input wire load,
    input wire [1:0] data1_depend,
    input wire [1:0] data2_depend,
    input wire [4:0] rd_in,
    input wire [5:0] ex_type_in,
    input wire [32:0] data1,
    input wire [32:0] data2,
    input wire [32:0] imm_extend,
    input wire [32:0] alu_data,
    input wire [32:0] mul_data,
    input wire mem_done,
    // Outputs
    output reg [1:0] state,
    output wire done,
    output wire [4:0] rd_wb,
    output wire [5:0] ex_type_out,
    output reg read_mem,
    output reg write_mem,
    output wire [31:0] addr,
    output wire addr_valid,
    output wire [31:0] write_data,
    output wire write_data_valid
);

    parameter READY = 2'b00;
    parameter LOAD = 2'b01;
    parameter EXECUTE = 2'b10;
    parameter DONE = 2'b11;

    reg [1:0] data1_depend_store, data2_depend_store;
    reg [4:0] rd_store;
    reg [5:0] ex_type_store;
    reg [32:0] data1_store, data2_store, alu_data_store, mul_data_store, imm_extend_store;
    reg [32:0] operand1, operand2;

    // Manage state
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= READY;
        end
        else begin
            case(state)
                READY: begin
                    if(load) state <= LOAD;
                    else state <= state;
                end
                LOAD: begin
                    if(read_mem) begin
                        if(addr_valid) state <= EXECUTE;
                        else state <= state;
                    end
                    else if(write_mem) begin
                        if(addr_valid & write_data_valid) state <= EXECUTE;
                        else state <= state;
                    end
                end
                EXECUTE: begin
                    if(mem_done) state <= READY;
                end
                DONE: begin
                    state <= READY;
                end
                default: state <= READY;
            endcase
        end
    end

    // Store data
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data1_depend_store <= 2'b00;
            data2_depend_store <= 2'b00;
            rd_store <= 5'd0;
            ex_type_store <= 5'd0;
            data1_store <= 33'd0;
            data2_store <= 33'd0;
            imm_extend_store <= 33'd0;
            alu_data_store <= 33'd0;
            mul_data_store <= 33'd0;
        end
        else begin
            if(load) begin
                data1_depend_store <= data1_depend;
                data2_depend_store <= data2_depend;
                rd_store <= rd_in;
                ex_type_store <= ex_type_in;
                data1_store <= data1;
                data2_store <= data2;
                imm_extend_store <= imm_extend;
                alu_data_store <= alu_data;
                mul_data_store <= mul_data;
            end
            else begin
                data1_depend_store <= data1_depend_store;
                data2_depend_store <= data2_depend_store;
                rd_store <= rd_store;
                ex_type_store <= ex_type_store;
                data1_store <= data1_store;
                data2_store <= data2_store;
                imm_extend_store <= imm_extend_store;
                alu_data_store <= (state == LOAD) ? alu_data : alu_data_store;
                mul_data_store <= (state == LOAD) ? mul_data : mul_data_store;
            end
        end
    end



    // Select calculate data
    always @(*) begin
        case(data1_depend_store)
            2'b00: operand1 = data1_store;
            2'b01: operand1 = alu_data_store;
            2'b10: operand1 = mul_data_store;
            default: operand1 = 33'd0;
        endcase

        case(data2_depend_store)
            2'b00: operand2 = data2_store;
            2'b01: operand2 = alu_data_store;
            2'b10: operand2 = mul_data_store;
            default: operand2 = 33'd0;
        endcase
    end

    // Assign outputs
    assign done = mem_done;
    assign rd_wb = mem_done & read_mem ? rd_store : 5'd0;
    assign ex_type_out = ex_type_store;
    assign addr = operand1[31:0] + imm_extend_store[31:0];
    assign addr_valid = operand1[32];
    assign write_data = operand2[31:0];
    assign write_data_valid = operand2[32] & write_mem;
    
    always @(*) begin
		case(ex_type_store)
			6'd21: begin
				read_mem = 1'b1;
                write_mem = 1'b0;
			end
			6'd22: begin
				read_mem = 1'b1;
                write_mem = 1'b0;
			end
			6'd23: begin
				read_mem = 1'b1;
                write_mem = 1'b0;
			end
			6'd24: begin
				read_mem = 1'b1;
                write_mem = 1'b0;
			end
			6'd25: begin
				read_mem = 1'b1;
                write_mem = 1'b0;
			end
            6'd26: begin
                read_mem = 1'b0;
				write_mem = 1'b1;
			end
			6'd27: begin
                read_mem = 1'b0;
				write_mem = 1'b1;
			end
			6'd28: begin
                read_mem = 1'b0;
				write_mem = 1'b1;
			end
			default: begin
				read_mem = 1'b0;
                write_mem = 1'b0;
			end
		endcase
    end

endmodule