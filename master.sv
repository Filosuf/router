`timescale 1 ns / 1 ps
//  timeunit 1ns;	
//  timeprecision 1ps;          
  

module master # (
              parameter DATA_WIDTH = 32,
              parameter ADDR_WIDTH = 32,
              parameter ADDR_CMD_START = 0,
              parameter ADDR_CMD_STOP = 1
            )
              (
                input logic rst,
                input logic clk,
                
                master_slave_if.MASTER  master_slave_bus 
              );                              
  
logic                  req; // запрос на выполнение транзакции
logic                  cmd; // “ип операции: 0 - read, 1 - write 
          
//-----------ROM--------------
logic [7:0] addr_rom;
logic [63:0] data_rom;
//-----------ROM-----END---------

logic ack_dd1;
logic req_dd1;

assign master_slave_bus.req = req;
//Questa не смогла смоделировать пам€ть на 32 бита €чеек
//assign master_slave_bus.addr = {data_rom[31:30],data_rom[14:0], data_rom[14:0]};
assign master_slave_bus.addr = {data_rom[31:30], 15'b0, data_rom[14:0]};
assign master_slave_bus.cmd = cmd;

//старшие 4 бита данных использованы дл€ переключени€ команд чтени€/записи
assign master_slave_bus.wdata = {data_rom[59:56],data_rom[59:32]}; 
//assign master_slave_bus.wdata = {4'b0,data_rom[59:32]};

assign cmd = data_rom[60]; //debug

always_ff @(posedge clk)
  begin
    if (rst)
      begin
        ack_dd1 <= 1'b1;
        req_dd1 <= 1'b0;
      end
    else  
      begin
        ack_dd1 <= master_slave_bus.ack;
        req_dd1 <= req;
      end
  end 
  
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        req <= 1'b1;
      end
    else
      if (master_slave_bus.ack && !ack_dd1)
        begin
          req <= 1'b0;
        end
      else if ((addr_rom <= ADDR_CMD_STOP))
        begin
          req <= 1'b1; 
        end
  end  
      

always_ff @(posedge clk)
  begin
    if (rst)
      begin
        addr_rom <= ADDR_CMD_START;
      end
    else
      if (master_slave_bus.ack && !ack_dd1 && (addr_rom <= ADDR_CMD_STOP))
        begin
          addr_rom <= addr_rom + 1;
        end
  end 

//assign addr_rom = (rst) ? '0 : (!master_slave_bus.ack && ack_dd1 && (addr_rom < 2)) ? (addr_rom + 1) : addr_rom; 
 
 master_data_rom master_cmd
 (
	.address(addr_rom),
	.clock(clk),
	.q(data_rom)
  );
//-------------------------------------------------------   
endmodule