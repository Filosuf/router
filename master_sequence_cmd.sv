`timescale 1 ns / 1 ps
//  timeunit 1ns;	
//  timeprecision 1ps;          
  

module master_sequence_cmd # (
              parameter ADDR_WIDTH = 32,
              parameter MASTER_N = 0
            )
              (
                input logic rst,
                input logic clk,
                input logic data_accept,
                
                output logic [6:0] master_N_cmd_rd_next,
                
                input logic ack_n,
                input logic cmd_n,
                input logic [ADDR_WIDTH-1:0] addr_n
              );

 logic ack_dd1;
 logic empty_d1;
 
 logic [1:0] master_n; //master_n = MASTER_N Ќомер ћастера
 
 logic [2:0] cmd_slave_0; //считает команды отправленные в один и тот же SLAVE от Master_0
 logic [2:0] cmd_slave_1; //считает команды отправленные в один и тот же SLAVE от Master_1
 logic [2:0] cmd_slave_2; //считает команды отправленные в один и тот же SLAVE от Master_2
 logic [2:0] cmd_slave_3; //считает команды отправленные в один и тот же SLAVE от Master_3
 
 fifo_if fifo_bus ();
 
 fifo # (
          .DATA_WIDTH(7),
          .FIFO_SIZE_EXP(3)
          )
fifo_route_slave_N (
                    .rst(rst),
                    .clk(clk),
                    .fifo_bus(fifo_bus)
                    );
            
assign master_n = MASTER_N;

 //--------------------------------------  
 //дл€ формировани€ строба
 always_ff @(posedge clk)
  begin
    if (rst)
      begin
        ack_dd1 <= '0;
        empty_d1 <= 1'b1;
      end
    else 
      begin
        ack_dd1 <= ack_n;
        empty_d1 <= fifo_bus.empty;
      end
  end
  
//«апоминаем в какой SLAVE отправили запросы, дл€ считывани€ в той же последовательности. FIFO.
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        fifo_bus.data_in <= '0;
        cmd_slave_0 <= '0;
        cmd_slave_1 <= '0;
        cmd_slave_2 <= '0;
        cmd_slave_3 <= '0;
      end
    else if (ack_n && !ack_dd1 && !fifo_bus.full && !cmd_n)
      begin
        case (addr_n[31:30]) //номер мастера, чей запрос был отправлен последним в Slave_0
              2'b00 : 
                begin
                  fifo_bus.data_in <= {master_n, 2'b00, cmd_slave_0};
                  cmd_slave_0 <= cmd_slave_0 + 1;
                  fifo_bus.put <= 1'b1;
                end
              2'b01 :
                begin
                  fifo_bus.data_in <= {master_n, 2'b01, cmd_slave_1};
                  cmd_slave_1 <= cmd_slave_1 + 1;
                  fifo_bus.put <= 1'b1;
                end
              2'b10 : 
                begin
                  fifo_bus.data_in <= {master_n, 2'b10, cmd_slave_2};
                  cmd_slave_2 <= cmd_slave_2 + 1;
                  fifo_bus.put <= 1'b1;
                end
              2'b11 : 
                begin
                  fifo_bus.data_in <= {master_n, 2'b11, cmd_slave_3};
                  cmd_slave_3 <= cmd_slave_3 + 1;
                  fifo_bus.put <= 1'b1;
                end    
  //            default: 
  //              begin 
  //              end         
        endcase
      end
    else
      begin
        fifo_bus.put <= 1'b0;
      end
  end
    
//—ообщаем ответ какого SLAVE должен быть отправлен в MASTER. FIFO.
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        master_N_cmd_rd_next <= 1'b0;
        fifo_bus.get <= 1'b0;
      end
    else if (data_accept)
      begin
        fifo_bus.get <= 1'b0;
      end
    else if (!empty_d1)
      begin
        master_N_cmd_rd_next <= fifo_bus.data_out;
        fifo_bus.get <= 1'b1;
      end
  end


//-------------------------------------------------------   
endmodule