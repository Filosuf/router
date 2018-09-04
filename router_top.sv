`timescale 1 ns / 1 ps
//  timeunit 1ns;	
//  timeprecision 1ps;          
  

module router_top # (
              parameter DATA_WIDTH = 32,
              parameter ADDR_WIDTH = 32
            )
              (
                input logic rst,
                input logic clk
              );
//определение стартового и конечого адреса памяти, где хранятся команды для MASTER              
parameter ADDR_CMD_START_0 = 0;
parameter ADDR_CMD_START_1 = 22;
parameter ADDR_CMD_START_2 = 44;
parameter ADDR_CMD_START_3 = 66;
parameter ADDR_CMD_STOP_0 = 21;
parameter ADDR_CMD_STOP_1 = 43;
parameter ADDR_CMD_STOP_2 = 65;
parameter ADDR_CMD_STOP_3 = 87;

master_slave_if  master_slave_bus_m0(); 
master_slave_if  master_slave_bus_s0();


//----------------ROUTER--------------------------------------- 
master_slave_if   m_r_bus_0();
master_slave_if   m_r_bus_1();
master_slave_if   m_r_bus_2();
master_slave_if   m_r_bus_3();
master_slave_if   r_s_bus_0();
master_slave_if   r_s_bus_1();
master_slave_if   r_s_bus_2();
master_slave_if   r_s_bus_3();

router # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
          )
router_inst (
          .rst(rst),
          .clk(clk),
          .m_r_bus_0(m_r_bus_0),//шина Master_0 <-> Router
          .m_r_bus_1(m_r_bus_1),//шина Master_1 <-> Router
          .m_r_bus_2(m_r_bus_2),//шина Master_2 <-> Router
          .m_r_bus_3(m_r_bus_3),//шина Master_3 <-> Router
          
          .r_s_bus_0(r_s_bus_0),//шина Router <-> Slave_0
          .r_s_bus_1(r_s_bus_1),//шина Router <-> Slave_1
          .r_s_bus_2(r_s_bus_2),//шина Router <-> Slave_2
          .r_s_bus_3(r_s_bus_3) //шина Router <-> Slave_3
          );
//----------------MASTER---------------------------------------               
master # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .ADDR_CMD_START(ADDR_CMD_START_0),
          .ADDR_CMD_STOP(ADDR_CMD_STOP_0)
          )
    master_n0 (
          .rst(rst),
          .clk(clk),
          .master_slave_bus(m_r_bus_0)
          );

master # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .ADDR_CMD_START(ADDR_CMD_START_1),
          .ADDR_CMD_STOP(ADDR_CMD_STOP_1)
          )
    master_n1 (
          .rst(rst),
          .clk(clk),
          .master_slave_bus(m_r_bus_1)
          );
master # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .ADDR_CMD_START(ADDR_CMD_START_2),
          .ADDR_CMD_STOP(ADDR_CMD_STOP_2)
          )
    master_n2 (
          .rst(rst),
          .clk(clk),
          .master_slave_bus(m_r_bus_2)
          );
master # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .ADDR_CMD_START(ADDR_CMD_START_3),
          .ADDR_CMD_STOP(ADDR_CMD_STOP_3)
          )
    master_n3 (
          .rst(rst),
          .clk(clk),
          .master_slave_bus(m_r_bus_3)
          );
//-----------------SLAVE-------------------------------------- 
  
slave # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
          )
    slave_n0 (
          .rst(rst),
          .clk(clk),
          .master_slave_bus(r_s_bus_0)
          );
          
slave # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
          )
    slave_n1 (
          .rst(rst),
          .clk(clk),
          .master_slave_bus(r_s_bus_1)
          );
          
slave # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
          )
    slave_n2 (
          .rst(rst),
          .clk(clk),
          .master_slave_bus(r_s_bus_2)
          );
          
slave # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
          )
    slave_n3 (
          .rst(rst),
          .clk(clk),
          .master_slave_bus(r_s_bus_3)
          );
endmodule