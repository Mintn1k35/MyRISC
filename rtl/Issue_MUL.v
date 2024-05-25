module Issue_MUL(
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
    input wire [32:0] alu_data,
    input wire [32:0] lsu_data,
    // Outputs
    output reg [1:0] state,
    output wire done,
    output wire [4:0] rd_wb,
    output wire [5:0] ex_type_out,
    output wire [31:0] operand1,
    output wire [31:0] operand2
);

    parameter READY = 2'b00;
    parameter LOAD = 2'b01;
    parameter EXECUTE = 2'b10;
    parameter DONE = 2'b11;
    reg [1:0] data1_depend_store, data2_depend_store;
    reg [32:0] data1_store, data2_store;
    reg [32:0] alu_data_store, lsu_data_store;
    reg [4:0] rd_store;
    reg [5:0] ex_type_store;
    reg [32:0] operand1_tmp, operand2_tmp;
    wire operand1_valid = operand1_tmp[32];
    wire operand2_valid = operand2_tmp[32];

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
                    if(operand1_valid & operand2_valid) state <= EXECUTE;
                    else state <= state;
                end
                EXECUTE: begin
                    state <= DONE;
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
            ex_type_store <= 6'd0;
            data1_store <= 33'd0;
            data2_store <= 33'd0;
            alu_data_store <= 33'd0;
            lsu_data_store <= 33'd0;
        end
        else begin
            if(load) begin
                data1_depend_store <= data1_depend;
                data2_depend_store <= data2_depend;
                rd_store <= rd_in;
                ex_type_store <= ex_type_in;
                data1_store <= data1;
                data2_store <= data2;
                alu_data_store <= alu_data;
                lsu_data_store <= lsu_data;
            end
            else begin
                data1_depend_store <= data1_depend_store;
                data2_depend_store <= data2_depend_store;
                rd_store <= rd_store;
                ex_type_store <= ex_type_store;
                data1_store <= data1_store;
                data2_store <= data2_store;
                alu_data_store <= (state == LOAD) ? alu_data : alu_data_store;
                lsu_data_store <= (state == LOAD) ? lsu_data : lsu_data_store;
            end
        end
    end

    always @(*) begin
        case(data1_depend_store)
            2'b00: operand1_tmp = data1_store;
            2'b01: operand1_tmp = alu_data_store;
            2'b11: operand1_tmp = lsu_data_store;
            default: operand1_tmp = 33'd0;
        endcase

        case(data2_depend_store)
            2'b00: operand2_tmp = data2_store;
            2'b01: operand2_tmp = alu_data_store;
            2'b11: operand2_tmp = lsu_data_store;
            default: operand2_tmp = 33'd0;
        endcase
    end

    // Assign outputs
    assign done = (state == DONE);
    assign rd_wb = (state == DONE) ? rd_store : 5'd0;
    assign ex_type_out = ex_type_store;
    assign operand1 = operand1_tmp;
    assign operand2 = operand2_tmp;
endmodule