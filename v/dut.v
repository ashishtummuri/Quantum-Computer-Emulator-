
`include "defines.vh"
//---------------------------------------------------------------------------
// DUT 
//---------------------------------------------------------------------------
module MyDesign(
//---------------------------------------------------------------------------
//System signals
  input wire reset_n                      ,  
  input wire clk                          ,

//---------------------------------------------------------------------------
//Control signals
  input wire dut_valid                    , 
  output reg dut_ready                   ,

//---------------------------------------------------------------------------
//q_state_input SRAM interface
  output wire                                               q_state_input_sram_write_enable  ,
  output wire [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_input_sram_write_address ,
  output wire [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_input_sram_write_data    ,
  output wire [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_input_sram_read_address  , 
  input  wire [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_input_sram_read_data     ,

//---------------------------------------------------------------------------
//q_state_output SRAM interface
  output wire                                                q_state_output_sram_write_enable  ,
  output wire [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_write_address ,
  output wire [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_write_data    ,
  output wire [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_read_address  , 
  input  wire [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_read_data     ,

//---------------------------------------------------------------------------
//scratchpad SRAM interface                                                       
  output wire                                                scratchpad_sram_write_enable        ,
  output wire [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0]     scratchpad_sram_write_address       ,
  output wire [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0]        scratchpad_sram_write_data          ,
  output wire [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0]     scratchpad_sram_read_address        , 
  input  wire [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0]        scratchpad_sram_read_data           ,

//---------------------------------------------------------------------------
//q_gates SRAM interface                                                       
  output wire                                                q_gates_sram_write_enable           ,
  output wire [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_write_address          ,
  output wire [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_write_data             ,
  output wire [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_read_address           ,  
  input  wire [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_read_data              
);

parameter DATA_UPPER_BOUND = `Q_GATES_SRAM_DATA_UPPER_BOUND - 1;
parameter ADDR_UPPER_BOUND = `Q_GATES_SRAM_ADDRESS_UPPER_BOUND - 1;

reg [3:0] current_state, next_state;
reg [3:0] addr_input_select, addr_output_select,  addr_scratch_select, addr_gates_select, matrix_count_select, length_of_matrix_select, row_selection, a_select, b_select, c_select, matrixcheck, next_result_select;
reg [15:0] length_of_matrix, matrix_count, current_row;
reg [15:0] next_length_of_matrix, next_matrix_count, next_row;
reg output_write_enable, scratch_write_enable, flag_negative;
reg [DATA_UPPER_BOUND:0]  a, b, c, next_result; 
wire [((DATA_UPPER_BOUND)/2):0]  mac_real, mac_imag, a_real, a_imag, b_imag, b_real, c_real, c_imag, mac_real_a, mac_real_b, mac_real_c, mac_imag_a,mac_imag_b,mac_imag_c; 
reg [((DATA_UPPER_BOUND)/2):0]  real_part_result, imag_part_result;
wire [DATA_UPPER_BOUND:0]  input_data, gates_data;
wire [DATA_UPPER_BOUND:0] result;
reg [ADDR_UPPER_BOUND:0] addr_input, addr_gates, addr_scratch, addr_output;
reg [ADDR_UPPER_BOUND:0]  next_addr_input, next_addr_gates, next_addr_scratch, next_addr_output;

  DW_fp_mac_inst FP_REAL ( 
    .inst_a(mac_real_a),
    .inst_b(mac_real_b),
    .inst_c(mac_real_c),
    .inst_rnd(3'b0),
    .z_inst(mac_real),
    .status_inst()
  );

  DW_fp_mac_inst FP_IMAG ( 
  .inst_a(mac_imag_a),
  .inst_b(mac_imag_b),
  .inst_c(mac_imag_c),
  .inst_rnd(3'b0),
  .z_inst(mac_imag),
  .status_inst()
  );

assign result = {real_part_result, imag_part_result};
assign {a_real, a_imag} = a;
assign {b_real, b_imag} = b;
assign {c_real, c_imag} = c;

assign mac_real_a = flag_negative? a_real : a_imag;
assign mac_real_b = flag_negative? b_real: {!b_imag[63],b_imag[62:0]};
assign mac_real_c = c_real;

assign mac_imag_a = flag_negative? a_real: a_imag;
assign mac_imag_b = flag_negative? b_imag: b_real;
assign mac_imag_c = c_imag;

always@ (posedge clk)
begin
  if (!reset_n)
  begin
    current_state <= 100'b0;
    {addr_input, addr_gates, addr_scratch, addr_output} <= 500'b0;
    real_part_result <= 100'b0;
    imag_part_result <= 100'b0;
  end
  else
    begin
      current_state <= next_state;
      addr_input <= next_addr_input;
      addr_output <= next_addr_output;
      length_of_matrix <= next_length_of_matrix; 
      matrix_count <= next_matrix_count;
      addr_scratch <= next_addr_scratch;
      addr_gates <= next_addr_gates;
      real_part_result <= next_result[127:64];
      imag_part_result <= next_result[63:0];
      matrixcheck <= matrix_count_select;
      current_row <= next_row;
  end 
end

always@(*) 
begin
  a_select = 10'd1;
  b_select = 10'd1;
  c_select = 10'd1;
  addr_input_select = 10'd1;
  addr_output_select = 10'd1;
  addr_scratch_select = 10'd1;
  addr_gates_select = 10'd1;
  row_selection = 10'd1;
  dut_ready = 0;
  next_state = 0;
  next_result_select = 1;
  matrix_count_select = 10'd1;
  length_of_matrix_select = 10'd1;
  flag_negative = 10'd1;
  output_write_enable = 0;
  scratch_write_enable = 0;

  casex (current_state)
    10'd0: begin
      a_select = 10'd0;
      b_select = 10'd0;
      c_select = 10'd0;
      row_selection = 10'd0;
      matrix_count_select = 10'd0;
      length_of_matrix_select = 10'd0;
      addr_input_select = 10'd0;
      addr_output_select = 10'd0;
      addr_scratch_select = 10'd0;
      addr_gates_select = 10'd0;
      dut_ready = 1;
      if (dut_valid)
      begin
        next_state = 10'd1;
      end
    end

    10'd1: 
    begin
      length_of_matrix_select = 10'd2;
      addr_input_select = 2;
      matrix_count_select = 10'd3;
      next_state = 12;
    end

    10'd2: 
    begin
      addr_gates_select = 10'd2;
      addr_input_select = 10'd2;
      next_state = 3;
      if (addr_input == length_of_matrix)
      begin
        next_state = 4;
        addr_input_select = 10'd3;
      end 
    end

    10'd3: 
    begin
      flag_negative = 0;
      c_select = 10'd1;
      next_state = 2;
      end

    10'd4: begin
      flag_negative = 0;
      c_select = 10'd1;
      addr_output_select = 10'd2; 
      addr_gates_select = 10'd1;
      addr_input_select = 10'd3;
      row_selection = 10'd2;
      next_result_select = 0;
      next_state = 2;
      output_write_enable = 1;

      if (current_row == length_of_matrix - 1)
        begin
          next_state = 5;
          addr_output_select = 10'd0;
          if (matrix_count == 1)
            next_state = 0;
        end 
      end

    10'd5: begin
      next_state = 6;
      matrix_count_select = 10'd2;
      addr_scratch_select = 10'd0;
      row_selection = 10'd0;
      a_select = 10'd2;
      next_result_select = 0;
      addr_gates_select = 10'd1;
      addr_output_select = 10'd0;
      
    end

    10'd6: begin
      a_select = 10'd2;
      addr_output_select = 10'd2;
      addr_gates_select = 10'd2;
      addr_scratch_select = 10'd2;
      scratch_write_enable = 1;
      next_state = 7;
      if (addr_output == (length_of_matrix - 1))
      begin
        addr_output_select = 10'd0;
        addr_scratch_select = 10'd0;
        next_state = 8;
      end
    end

    10'd7: begin
      flag_negative = 0;
      a_select = 10'd2;
      next_state = 10'd6;
    end

    10'd8: begin
      flag_negative = 0;
      a_select = 10'd2;
      addr_output_select = 10'd2;
      row_selection = 10'd2;
      next_result_select = 0;
      row_selection = 10'd2;
      output_write_enable = 1;
      next_state = 9;
      if (current_row == (length_of_matrix - 1))
      next_state = 5;
    end


    10'd9: begin
      a_select = 10'd3;
      next_state = 10;
      addr_scratch_select = 10'd2;
      addr_gates_select = 10'd2;
      if (addr_scratch == (length_of_matrix - 1))
      begin
      next_state = 11;
      addr_scratch_select = 10'd0;
      end
    end

    10'd10: begin
      a_select = 10'd3;
      flag_negative = 0;
      next_state = 9;
    end

    10'd11: begin
      next_result_select = 0;
      flag_negative = 0;
      a_select = 10'd3;
      output_write_enable = 1;
      addr_output_select = 10'd2;
      addr_scratch_select = 10'd0;
      row_selection = 10'd2;
      next_state = 9;
      if (current_row == length_of_matrix - 1)
      begin
        next_state = 5;
        addr_output_select = 10'd0;
        if (matrix_count == 1) 
          next_state = 0;
      end
    end

    10'd12: 
    begin
      c_select = 10'd0;
      next_state = 2;
    end

  endcase
end

always @(*)
begin
  a = 0;
  b = 0;
  c = 0;
  next_addr_input = 0;
  next_addr_output = 0;
  next_addr_scratch = 0;
  next_addr_gates = 0;
  next_row = 0;
  next_length_of_matrix = 0;
  next_matrix_count = 0;
  next_result = 0;

  next_result = (next_result_select == 10'd1) ? {mac_real, mac_imag} : 0;

  a = (a_select == 10'd1) ? q_state_input_sram_read_data :
      (a_select == 10'd2) ? q_state_output_sram_read_data :
      (a_select == 10'd3) ? scratchpad_sram_read_data : 0;

  b = (b_select == 10'd1) ? q_gates_sram_read_data : 0;

  c = (c_select == 10'd1) ? result : 0;

  next_addr_input = (addr_input_select == 10'd1) ? addr_input :
                       (addr_input_select == 10'd2) ? addr_input + 1 :
                       (addr_input_select == 10'd3) ? 1 : 0;

  next_addr_output = (addr_output_select == 10'd1) ? addr_output :
                        (addr_output_select == 10'd2) ? addr_output + 1 : 0;

  next_addr_gates = (addr_gates_select == 10'd1) ? addr_gates :
                       (addr_gates_select == 10'd2) ? addr_gates + 1 : 0;

  next_addr_scratch = (addr_scratch_select == 10'd1) ? addr_scratch :
                         (addr_scratch_select == 10'd2) ? addr_scratch + 1 : 0;

  next_matrix_count = (matrix_count_select == 10'd1) ? matrix_count :
                      (matrix_count_select == 10'd2) ? matrix_count - 1 :
                      (matrix_count_select == 10'd3) ? q_state_input_sram_read_data[63:0] : 0;

  next_length_of_matrix = (length_of_matrix_select == 10'd1) ? length_of_matrix :
                       (length_of_matrix_select == 10'd2) ? 1 << q_state_input_sram_read_data[127:64] : 0;

  next_row = (row_selection == 10'd1) ? current_row :
             (row_selection == 10'd2) ? current_row + 1 : 0;
end

  assign q_gates_sram_write_enable = 0;
  assign q_gates_sram_write_address = 0;
  assign q_gates_sram_read_address = addr_gates;
  assign q_gates_sram_write_data = 0;

  assign q_state_output_sram_write_enable  = output_write_enable;
  assign q_state_output_sram_write_address  = addr_output;
  assign q_state_output_sram_read_address  = addr_output;
  assign q_state_output_sram_write_data = {mac_real, mac_imag};

  assign q_state_input_sram_write_enable = 0;
  assign q_state_input_sram_write_address = 0;
  assign q_state_input_sram_read_address = addr_input;
  assign q_state_input_sram_write_data = 0;

  assign scratchpad_sram_write_enable= scratch_write_enable;
  assign scratchpad_sram_write_address = addr_scratch;
  assign scratchpad_sram_read_address = addr_scratch;
  assign scratchpad_sram_write_data = q_state_output_sram_read_data;

endmodule

module DW_fp_mac_inst #(
  parameter inst_sig_width = 52,
  parameter inst_exp_width = 11,
  parameter inst_ieee_compliance = 1 
) ( 
  input wire [inst_sig_width+inst_exp_width : 0] inst_a,
  input wire [inst_sig_width+inst_exp_width : 0] inst_b,
  input wire [inst_sig_width+inst_exp_width : 0] inst_c,
  input wire [2 : 0] inst_rnd,
  output wire [inst_sig_width+inst_exp_width : 0] z_inst,
  output wire [7 : 0] status_inst
);

  DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) 
  );

endmodule
