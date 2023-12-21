
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
  output wire dut_ready                   ,

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


  event start;
  event complete;
  bit [31:0] N;
  bit [31:0] M;

  bit dut_ready_r;

  initial
  begin
    wait(!reset_n);
    wait(clk);
    wait(!clk);
    dut_ready_r = 1;
    wait(reset_n);
    wait(clk);
    wait(!clk);
    forever
    begin
      wait(clk);
      wait(!clk);
      dut_ready_r = 1;
      fork
        begin
          wait(!reset_n);
          wait(clk);
          wait(!clk);
          dut_ready_r = 1;
        end
        begin
          forever
          begin
            wait(dut_valid);
            wait(!clk);
            dut_ready_r = 0;
            wait(!dut_valid);
            ->start;
            @(complete);
            wait(!clk);
            dut_ready_r = 1;
          end
        end
      join_any
      wait(reset_n);
    end
  end
    
  assign dut_ready=dut_ready_r;

  real input_q_array_real[int];
  real input_q_array_img[int];
  bit                                               q_state_input_sram_write_enable_r ; 
  bit [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_input_sram_write_address_r; 
  bit [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_input_sram_write_data_r   ; 
  bit [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_input_sram_read_address_r ;  
  bit [63:0] temp;
  real temp_real;
  event start_download;

  initial
  begin
    wait(!reset_n);
    wait(!clk);
    q_state_input_sram_write_enable_r   = 0;
    q_state_input_sram_write_address_r  = 0;
    q_state_input_sram_write_data_r     = 0;
    q_state_input_sram_read_address_r   = 0;
    wait(reset_n);
    forever
    begin
      @(start)
      wait(clk);
      wait(!clk);
      q_state_input_sram_read_address_r = 0;
      wait(clk);
      wait(!clk);
      q_state_input_sram_read_address_r = 1;
      N = 1 << q_state_input_sram_read_data[127:64];
      M = q_state_input_sram_read_data[63:0];
      temp = q_state_input_sram_read_data[63:0];
      ->start_download;
      for(int i=1;i<N;i++)
      begin
        wait(clk);
        wait(!clk);
        q_state_input_sram_read_address_r = i+1;
        input_q_array_real[i-1] = $bitstoreal(q_state_input_sram_read_data[127:64]);
        input_q_array_img[i-1] = $bitstoreal(q_state_input_sram_read_data[63:0]);
        temp = q_state_input_sram_read_data[63:0];
        temp_real = $bitstoreal(temp);
      end
      wait(clk);
      wait(!clk);
      input_q_array_real[N-1] = $bitstoreal(q_state_input_sram_read_data[127:64]);
      input_q_array_img[N-1] = $bitstoreal(q_state_input_sram_read_data[63:0]);
      temp = q_state_input_sram_read_data[63:0];
      temp_real = $bitstoreal(temp);
    end
  end

  assign q_state_input_sram_write_enable  = q_state_input_sram_write_enable_r ; 
  assign q_state_input_sram_write_address = q_state_input_sram_write_address_r; 
  assign q_state_input_sram_write_data    = q_state_input_sram_write_data_r   ; 
  assign q_state_input_sram_read_address  = q_state_input_sram_read_address_r ;  
    
  real q_gates_real [int][int];
  real q_gates_img  [int][int];
  bit                                                 q_gates_sram_write_enable_r ; 
  bit  [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_write_address_r; 
  bit  [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_write_data_r   ; 
  bit  [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_read_address_r ;  
  integer gate_offset;
  event download_complete;
  event compute_complete;
  event compute_done;
  event done;
  integer ii;
  integer jj;

  initial
  begin
    wait(!reset_n);
    wait(clk);
    q_gates_sram_write_enable_r   = 0;
    q_gates_sram_write_address_r  = 0;
    q_gates_sram_write_data_r     = 0;
    q_gates_sram_read_address_r   = 0;
    gate_offset = 0;
    wait(!clk);
    wait(clk);
    wait(reset_n);
    forever
    begin
      fork
        begin
          wait(!reset_n);
          wait(clk);
          wait(!clk);
          q_gates_sram_read_address_r   = 0;
        end
        begin
          forever
          begin
            @(start_download)
            for(int gate_offset=0;gate_offset<M;gate_offset++)
            begin
              wait(clk);
              wait(!clk);
              q_gates_sram_read_address_r = gate_offset*N*N;
              wait(clk);
              wait(!clk);
              for(int i=0;i<N;i++)
              begin
                for(int j=0;j<N;j++)
                begin
                wait(clk);
                wait(!clk);
                q_gates_sram_read_address_r = gate_offset*N*N+i*N+j+1;
                q_gates_real[i][j] = $bitstoreal(q_gates_sram_read_data[127:64]);
                q_gates_img[i][j] = $bitstoreal(q_gates_sram_read_data[63:0]);
                end
              end
              wait(clk);
              wait(!clk);
              ->download_complete;
              wait(clk);
              wait(!clk);
              wait(compute_complete);
            end
            wait(clk);
            wait(!clk);
          end
        end
      join_any
      wait(reset_n);
    end
  end


  function real complex_mult_real(real X,real Y,real Z,real W);
    return (X*Z) - (Y*W);
  endfunction

  function real complex_mult_img(real X,real Y,real Z,real W);
    return (X*W) + (Y*Z);
  endfunction


  assign q_gates_sram_write_enable   = q_gates_sram_write_enable_r  ;
  assign q_gates_sram_write_address  = q_gates_sram_write_address_r ;
  assign q_gates_sram_write_data     = q_gates_sram_write_data_r    ;
  assign q_gates_sram_read_address   = q_gates_sram_read_address_r  ;


  real output_q_array_real[int];
  real output_q_array_img[int];


  initial
  begin
    forever
    begin
      @(start_download);
      repeat(M)
      begin
        @(download_complete);
        wait(clk);
        wait(!clk);
        for(int i=0;i<N;i++)
        begin
          output_q_array_real[i] = 0.0;
          output_q_array_img[i] = 0.0;
        end
        wait(clk);
        wait(!clk);
        for(int i=0;i<N;i++)
        begin
          for(int k=0;k<N;k++)
          begin
            wait(clk);
            wait(!clk);
            output_q_array_real[i] = output_q_array_real[i] + ((input_q_array_real[k]*q_gates_real[i][k])-(input_q_array_img[k]*q_gates_img[i][k]));      
            output_q_array_img[i] = output_q_array_img[i] + ((input_q_array_real[k]*q_gates_img[i][k])+(input_q_array_img[k]*q_gates_real[i][k]));      
          end
        end
        wait(clk);
        wait(!clk);
        for(int i=0;i<N;i++)
        begin
          input_q_array_real[i] = output_q_array_real[i];
          input_q_array_img[i] = output_q_array_img[i];
        end
        wait(clk);
        wait(!clk);
        ->compute_complete;
      end
      ->compute_done;
    end
  end


  bit                                                q_state_output_sram_write_enable_r ; 
  bit [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_write_address_r; 
  bit [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_write_data_r   ; 
  bit [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_read_address_r ;  

  initial
  begin
    wait(!reset_n);
    wait(clk);
    wait(!clk);
    q_state_output_sram_write_enable_r  = 0; 
    q_state_output_sram_write_address_r = 0;
    q_state_output_sram_write_data_r    = 0;
    q_state_output_sram_read_address_r  = 0;
    
    wait(reset_n);
    forever
    begin
      fork
        begin
          wait(!reset_n);
          wait(clk);
          wait(!clk);
          q_state_output_sram_write_enable_r  = 0; 
          q_state_output_sram_write_address_r = 0;
          q_state_output_sram_write_data_r    = 0;
          q_state_output_sram_read_address_r  = 0;
        end
        begin
          forever
          begin
            @(compute_done)
            wait(clk);
            wait(!clk);
            for(int i=0;i<N;i++)
            begin
              wait(clk);
              wait(!clk);
              q_state_output_sram_write_enable_r  = 1; 
              q_state_output_sram_write_address_r = i;
              q_state_output_sram_write_data_r    = {$realtobits(output_q_array_real[i]),$realtobits(output_q_array_img[i])};
            end
            wait(clk);
            wait(!clk);
            q_state_output_sram_write_enable_r  = 0; 
            wait(clk);
            wait(!clk);
            ->complete;
          end
        end
      join_any
      wait(reset_n);
    end
  end

  assign q_state_output_sram_write_enable   = q_state_output_sram_write_enable_r ; 
  assign q_state_output_sram_write_address  = q_state_output_sram_write_address_r; 
  assign q_state_output_sram_write_data     = q_state_output_sram_write_data_r   ; 
  assign q_state_output_sram_read_address   = q_state_output_sram_read_address_r ;  

endmodule
