module Core(
    input wire clk,
    input wire rst_n,
    input wire power,
    input wire restart,
    // Signal for ICache_Controller
    input wire [63:0] fetch_instr_pc,
    output wire stop,
    output wire stop_fetch,
    output wire ecall,
    output wire j_accept,
    output wire [31:0] j_addr,
    // Signal for DCache_Controller
    output wire read_mem,
    output wire write_mem,
    output wire [31:0] addr,
    output wire addr_valid,
    output wire [31:0] write_data,
    output wire write_data_valid,
    input wire mem_done,
    input wire [31:0] dcache_data,
    // Signal for MUL IP
    output wire [31:0] operand1_mul,
    output wire [31:0] operand2_mul,
    input wire [63:0] mul_result,
    // Signal for CDMA_Control,
    input wire dma_done,
    output wire dma_en,
    output wire load_os
    // output wire [31:0] read_addr,
    // output wire [31:0] write_addr,
    // output wire [31:0] byte_length
);

    wire [32:0] data1_alu, data2_alu;
    wire [31:0] rs1_data, rs2_data, imm_extend, alu_result, pc4, fifo_data, lsu_result;
    wire [31:0] operand1_alu, operand2_alu, write_data_tmp;
    wire [5:0] ex_type, count, ex_type_alu, ex_type_mul, ex_type_lsu;
    wire [4:0] rs1, rs2, rd, rd1_wb, rd2_wb, rd3_wb;
    wire [1:0] alu_state, mul_state, lsu_state, data1_depend, data2_depend;
    wire store_mem, alu, mul, lsu, jal, jalr, branch, auipc, imm, lui, write_en1, write_en2, write_en3, alu_done,
    mul_done, lsu_done, full, empty, read_en, j_accept_tmp, j_wait_tmp, alu_load, mul_load, lsu_load, reset_all;

    wire [31:0] pc = fetch_instr_pc[63:32];
    wire [31:0] instr = fetch_instr_pc[31:0];
    wire load_os;
    assign pc4 = pc + 32'd4;
    assign stop = j_wait_tmp;
    assign j_accept = j_accept_tmp & !j_wait_tmp;


    Instr_Decode Instr_Decode_Instance(instr, rs1, rs2, rd, alu, mul, lsu, jal, jalr, branch, 
    auipc, imm, lui, ecall, store_mem, ex_type);

    Imm_Extend Imm_Extend_Instance(instr, imm_extend);

    Register_File Register_File_Instance(clk, reset_all, rs1, rs2, rd1_wb, rd2_wb, rd3_wb, alu_result, mul_result[31:0], lsu_result, 
    alu_done, mul_done, lsu_done, rs1_data, rs2_data);

    Branch_Excute Branch_Excute_Instance(instr, imm_extend, rs1_data, rs2_data, pc, data1_depend, data2_depend, j_accept_tmp, j_wait_tmp, j_addr);

    ScoreBoard ScoreBoard_Instance(clk, reset_all, rs1, rs2, rd, alu, mul, lsu, alu_state, mul_state, lsu_state, alu_done,
    mul_done, lsu_done, rd1_wb, rd2_wb, rd3_wb, store_mem, stop_fetch, alu_load, mul_load, lsu_load, data1_depend, data2_depend);

    assign data1_alu = auipc ? {1'b1, pc} : lui ? {1'b1, 32'd0} : {1'b1, rs1_data};
    assign data2_alu = (auipc | lui | imm) ? {1'b1, imm_extend} : (jal | jalr) ? {1'b1, pc4} : {1'b1, rs2_data}; 

    Issue_ALU Issue_ALU_Instance(clk, reset_all, alu_load, data1_depend, data2_depend, rd, ex_type, data1_alu, 
    data2_alu, {mul_done, mul_result[31:0]}, {lsu_done, lsu_result}, alu_state, alu_done, rd1_wb, ex_type_alu, operand1_alu,
    operand2_alu);

    ALU ALU_Instance(operand1_alu, operand2_alu, ex_type_alu, alu_result);

    Issue_MUL Issue_MUL_Instance(clk, reset_all, mul_load, data1_depend, data2_depend, rd, ex_type, {1'b1, rs1_data},
    {1'b1, rs2_data}, {alu_done, alu_result}, {lsu_done, lsu_result}, mul_state, mul_done, rd2_wb, ex_type_mul, operand1_mul,
    operand2_mul);

    Issue_LSU Issue_LSU_Instance(clk, reset_all, lsu_load, data1_depend, data2_depend, rd, ex_type, {1'b1, rs1_data},
    {1'b1, rs2_data}, {1'b1, imm_extend}, {alu_done, alu_result}, {mul_done, mul_result[31:0]}, mem_done, lsu_state, lsu_done,
    rd3_wb, ex_type_lsu, read_mem, write_mem, addr, addr_valid, write_data_tmp, write_data_valid);

    LSU LSU_Instance(ex_type_lsu, write_data_tmp, dcache_data, write_data, lsu_result);


    Core_State Core_State_Instance(clk, rst_n, power, restart, dma_done, reset_all, load_os);
    // assign dma_en = load_os;
endmodule