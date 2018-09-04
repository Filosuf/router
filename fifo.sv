`timescale 1 ns / 1 ps
//  timeunit 1ns;	
//  timeprecision 1ps;          
  

module fifo # (
              parameter DATA_WIDTH = 32,
              parameter FIFO_SIZE_EXP = 2   // размер буфера = 2^FIFO_SIZE_EXP
            )
              (
                input logic rst,
                input logic clk,
                
                fifo_if.SRC  fifo_bus 
              );                              
  

parameter FIFO_SIZE = 1<<FIFO_SIZE_EXP; // размер буфера

logic [DATA_WIDTH-1:0] fifo_buf [FIFO_SIZE-1:0];
logic [FIFO_SIZE_EXP-1:0] buf_start;
logic [FIFO_SIZE_EXP-1:0] buf_end;
logic full;
logic empty;

logic get_dd1;
logic put_dd1;

assign fifo_bus.full  = full;
assign fifo_bus.empty = empty;

//------------------------------------------------------- 
//выделение фронта сигналов get, put
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        get_dd1 <= 1'b0;
        put_dd1 <= 1'b0;
      end
    else
      begin
        get_dd1 <= fifo_bus.get;
        put_dd1 <= fifo_bus.put;
      end
  end 
  
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        full       <= 1'b0;
        empty      <= 1'b1;
        //fifo_bus.data_out <= '0;
        buf_start  <= 1'b0;
        buf_end    <= 1'b0;
      end
    else
      begin
        if (fifo_bus.put && !put_dd1 && !full) //пришел новый запрос на запись и буфер не полон
          begin
            fifo_buf[buf_end] <= fifo_bus.data_in;
            buf_end = buf_end + 1;
            empty <= 1'b0;
            if (buf_end == buf_start)
              begin
                full <= 1'b1;
              end
          end
        if (fifo_bus.get && !get_dd1 && !empty) //пришел новый запрос на чтение и буфер не пустой
          begin
            fifo_bus.data_out <= fifo_buf[buf_start];
            buf_start = buf_start + 1;
            full <= 1'b0;
            if (buf_end == buf_start)
              begin
                empty <= 1'b1;
              end
          end
       
      end
  end 
//-------------------------------------------------------   
endmodule