module Core_State(
    input wire clk,
    input wire rst_n,
    input wire power,
    input wire  restart,
    input wire load_os_done,
    output wire reset_all,
    output wire load_os
);
    parameter SHUT_DOWN = 2'b00;
    parameter RESET_ALL = 2'b01;
    parameter LOAD_OS = 2'b10;
    parameter WORKING = 2'b11;

    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= SHUT_DOWN;
        end
        else begin
            case(state)
                SHUT_DOWN: begin
                    if(power) state <= RESET_ALL;
                    else state <= state;
                end
                RESET_ALL: begin
                    state <= LOAD_OS;
                end
                LOAD_OS: begin
                    if(load_os_done) state <= WORKING;
                    else state <= state;
                end
                WORKING: begin
                    if(restart) state <= RESET_ALL;
                    else state <= state;
                end
                default: begin
                    state <= SHUT_DOWN;
                end
            endcase
        end
    end

    assign reset_all = (state == RESET_ALL);
    assign load_os = (state == LOAD_OS);
endmodule