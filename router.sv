`timescale 1 ns / 1 ps
//  timeunit 1ns;	
//  timeprecision 1ps;          
  

module router # (
              parameter DATA_WIDTH = 32,
              parameter ADDR_WIDTH = 32
            )
              (
                input logic rst,
                input logic clk,
                
                master_slave_if.SLAVE   m_r_bus_0, //шина Master_0 -> Router
                master_slave_if.SLAVE   m_r_bus_1, //шина Master_1 -> Router
                master_slave_if.SLAVE   m_r_bus_2, //шина Master_2 -> Router
                master_slave_if.SLAVE   m_r_bus_3, //шина Master_3 -> Router
                
                master_slave_if.MASTER  r_s_bus_0, //шина Router -> Slave_0
                master_slave_if.MASTER  r_s_bus_1, //шина Router -> Slave_1
                master_slave_if.MASTER  r_s_bus_2, //шина Router -> Slave_2
                master_slave_if.MASTER  r_s_bus_3 //шина Router -> Slave_3
              );
 
master_slave_if   m0_s0_bus(), m0_s1_bus(), m0_s2_bus(), m0_s3_bus(); //шина Master_0 -> Router
master_slave_if   m1_s0_bus(), m1_s1_bus(), m1_s2_bus(), m1_s3_bus(); //шина Master_1 -> Router
master_slave_if   m2_s0_bus(), m2_s1_bus(), m2_s2_bus(), m2_s3_bus(); //шина Master_2 -> Router
master_slave_if   m3_s0_bus(), m3_s1_bus(), m3_s2_bus(), m3_s3_bus(); //шина Master_3 -> Router

master_slave_if   m_r_bus_0_rd(); //шина Master_0 -> Router
master_slave_if   m_r_bus_1_rd(); //шина Master_1 -> Router
master_slave_if   m_r_bus_2_rd(); //шина Master_2 -> Router
master_slave_if   m_r_bus_3_rd(); //шина Master_3 -> Router
              
//-------------MASTER_0-----------------------------
logic [6:0] master_0_cmd_rd_next; 

//-------------MASTER_1-----------------------------
logic [6:0] master_1_cmd_rd_next; 

//-------------MASTER_2-----------------------------
logic [6:0] master_2_cmd_rd_next; 

//-------------MASTER_3-----------------------------
logic [6:0] master_3_cmd_rd_next; 


//-------------SLAVE_0-----------------
logic [DATA_WIDTH-1:0] data_in_buf_router_0;
logic [6:0] addr_in_buf_router_0;
logic resp_0;
logic valid_in_0;
logic valid_out_0;
logic wr_en_dpram_0;
logic [6:0] addr_wr_dpram_0;
//-------------SLAVE_1-----------------
logic [DATA_WIDTH-1:0] data_in_buf_router_1;
logic [6:0] addr_in_buf_router_1;
logic resp_1;
logic valid_in_1;
logic valid_out_1;
logic wr_en_dpram_1;
logic [6:0] addr_wr_dpram_1;
//-------------SLAVE_2-----------------
logic [DATA_WIDTH-1:0] data_in_buf_router_2;
logic [6:0] addr_in_buf_router_2;
logic resp_2;
logic valid_in_2;
logic valid_out_2;
logic wr_en_dpram_2;
logic [6:0] addr_wr_dpram_2;
//-------------SLAVE_3-----------------
logic [DATA_WIDTH-1:0] data_in_buf_router_3;
logic [6:0] addr_in_buf_router_3;
logic resp_3;
logic valid_in_3;
logic valid_out_3;
logic wr_en_dpram_3;
logic [6:0] addr_wr_dpram_3;

//------------------M_R_BUS_N--------------------
assign m_r_bus_0.ack   = m0_s0_bus.ack && m0_s1_bus.ack && m0_s2_bus.ack && m0_s3_bus.ack; 
assign m_r_bus_0.rdata = m_r_bus_0_rd.rdata;
assign m_r_bus_0.resp  = m_r_bus_0_rd.resp;

assign m_r_bus_1.ack   = m1_s0_bus.ack && m1_s1_bus.ack && m1_s2_bus.ack && m1_s3_bus.ack; 
assign m_r_bus_1.rdata = m_r_bus_1_rd.rdata;
assign m_r_bus_1.resp  = m_r_bus_1_rd.resp;

assign m_r_bus_2.ack   = m2_s0_bus.ack && m2_s1_bus.ack && m2_s2_bus.ack && m2_s3_bus.ack; 
assign m_r_bus_2.rdata = m_r_bus_2_rd.rdata;
assign m_r_bus_2.resp  = m_r_bus_2_rd.resp;

assign m_r_bus_3.ack   = m3_s0_bus.ack && m3_s1_bus.ack && m3_s2_bus.ack && m3_s3_bus.ack; 
assign m_r_bus_3.rdata = m_r_bus_3_rd.rdata;
assign m_r_bus_3.resp  = m_r_bus_3_rd.resp;

//------------------MASTER_N_SLAVE_N--------------------
//------------------MASTER_0_SLAVE_N--------------------
assign m0_s0_bus.req   = m_r_bus_0.req; 
assign m0_s0_bus.addr  = m_r_bus_0.addr;
assign m0_s0_bus.cmd   = m_r_bus_0.cmd;
assign m0_s0_bus.wdata = m_r_bus_0.wdata;

assign m0_s1_bus.req   = m_r_bus_0.req; 
assign m0_s1_bus.addr  = m_r_bus_0.addr;
assign m0_s1_bus.cmd   = m_r_bus_0.cmd;
assign m0_s1_bus.wdata = m_r_bus_0.wdata;

assign m0_s2_bus.req   = m_r_bus_0.req; 
assign m0_s2_bus.addr  = m_r_bus_0.addr;
assign m0_s2_bus.cmd   = m_r_bus_0.cmd;
assign m0_s2_bus.wdata = m_r_bus_0.wdata;

assign m0_s3_bus.req   = m_r_bus_0.req; 
assign m0_s3_bus.addr  = m_r_bus_0.addr;
assign m0_s3_bus.cmd   = m_r_bus_0.cmd;
assign m0_s3_bus.wdata = m_r_bus_0.wdata;
//------------------MASTER_1_SLAVE_N--------------------
assign m1_s0_bus.req   = m_r_bus_1.req; 
assign m1_s0_bus.addr  = m_r_bus_1.addr;
assign m1_s0_bus.cmd   = m_r_bus_1.cmd;
assign m1_s0_bus.wdata = m_r_bus_1.wdata;

assign m1_s1_bus.req   = m_r_bus_1.req; 
assign m1_s1_bus.addr  = m_r_bus_1.addr;
assign m1_s1_bus.cmd   = m_r_bus_1.cmd;
assign m1_s1_bus.wdata = m_r_bus_1.wdata;

assign m1_s2_bus.req   = m_r_bus_1.req; 
assign m1_s2_bus.addr  = m_r_bus_1.addr;
assign m1_s2_bus.cmd   = m_r_bus_1.cmd;
assign m1_s2_bus.wdata = m_r_bus_1.wdata;

assign m1_s3_bus.req   = m_r_bus_1.req; 
assign m1_s3_bus.addr  = m_r_bus_1.addr;
assign m1_s3_bus.cmd   = m_r_bus_1.cmd;
assign m1_s3_bus.wdata = m_r_bus_1.wdata;
//------------------MASTER_2_SLAVE_N--------------------
assign m2_s0_bus.req   = m_r_bus_2.req; 
assign m2_s0_bus.addr  = m_r_bus_2.addr;
assign m2_s0_bus.cmd   = m_r_bus_2.cmd;
assign m2_s0_bus.wdata = m_r_bus_2.wdata;

assign m2_s1_bus.req   = m_r_bus_2.req; 
assign m2_s1_bus.addr  = m_r_bus_2.addr;
assign m2_s1_bus.cmd   = m_r_bus_2.cmd;
assign m2_s1_bus.wdata = m_r_bus_2.wdata;

assign m2_s2_bus.req   = m_r_bus_2.req; 
assign m2_s2_bus.addr  = m_r_bus_2.addr;
assign m2_s2_bus.cmd   = m_r_bus_2.cmd;
assign m2_s2_bus.wdata = m_r_bus_2.wdata;

assign m2_s3_bus.req   = m_r_bus_2.req; 
assign m2_s3_bus.addr  = m_r_bus_2.addr;
assign m2_s3_bus.cmd   = m_r_bus_2.cmd;
assign m2_s3_bus.wdata = m_r_bus_2.wdata;
//------------------MASTER_3_SLAVE_N--------------------
assign m3_s0_bus.req   = m_r_bus_3.req; 
assign m3_s0_bus.addr  = m_r_bus_3.addr;
assign m3_s0_bus.cmd   = m_r_bus_3.cmd;
assign m3_s0_bus.wdata = m_r_bus_3.wdata;

assign m3_s1_bus.req   = m_r_bus_3.req; 
assign m3_s1_bus.addr  = m_r_bus_3.addr;
assign m3_s1_bus.cmd   = m_r_bus_3.cmd;
assign m3_s1_bus.wdata = m_r_bus_3.wdata;

assign m3_s2_bus.req   = m_r_bus_3.req; 
assign m3_s2_bus.addr  = m_r_bus_3.addr;
assign m3_s2_bus.cmd   = m_r_bus_3.cmd;
assign m3_s2_bus.wdata = m_r_bus_3.wdata;

assign m3_s3_bus.req   = m_r_bus_3.req; 
assign m3_s3_bus.addr  = m_r_bus_3.addr;
assign m3_s3_bus.cmd   = m_r_bus_3.cmd;
assign m3_s3_bus.wdata = m_r_bus_3.wdata;

//------------------M_R_BUS_N_RD--------------------
assign m_r_bus_0_rd.req   = m_r_bus_0.req; 
assign m_r_bus_0_rd.addr  = m_r_bus_0.addr;
assign m_r_bus_0_rd.cmd   = m_r_bus_0.cmd;
assign m_r_bus_0_rd.wdata = m_r_bus_0.wdata;

assign m_r_bus_1_rd.req   = m_r_bus_1.req; 
assign m_r_bus_1_rd.addr  = m_r_bus_1.addr;
assign m_r_bus_1_rd.cmd   = m_r_bus_1.cmd;
assign m_r_bus_1_rd.wdata = m_r_bus_1.wdata;

assign m_r_bus_2_rd.req   = m_r_bus_2.req; 
assign m_r_bus_2_rd.addr  = m_r_bus_2.addr;
assign m_r_bus_2_rd.cmd   = m_r_bus_2.cmd;
assign m_r_bus_2_rd.wdata = m_r_bus_2.wdata;

assign m_r_bus_3_rd.req   = m_r_bus_3.req; 
assign m_r_bus_3_rd.addr  = m_r_bus_3.addr;
assign m_r_bus_3_rd.cmd   = m_r_bus_3.cmd;
assign m_r_bus_3_rd.wdata = m_r_bus_3.wdata;
//----------MASTER_N_SLAVE_N----END----------------

//-------------MASTER_0-----------------------------
 //master_sequence_cmd
master_sequence_cmd # (
          .ADDR_WIDTH(ADDR_WIDTH),
          .MASTER_N(0)
          )
master_sequence_cmd_0 (
                      .rst(rst),
                      .clk(clk),
                      .data_accept(m_r_bus_0.resp), 
                      .master_N_cmd_rd_next(master_0_cmd_rd_next), 
                      .ack_n(m_r_bus_0.ack),
                      .cmd_n(m_r_bus_0.cmd),
                      .addr_n(m_r_bus_0.addr)
                      );
//-------------MASTER_1-----------------------------
 //master_sequence_cmd
master_sequence_cmd # (
          .ADDR_WIDTH(ADDR_WIDTH),
          .MASTER_N(1)
          )
master_sequence_cmd_1 (
                      .rst(rst),
                      .clk(clk),
                      .data_accept(m_r_bus_1.resp), 
                      .master_N_cmd_rd_next(master_1_cmd_rd_next), 
                      .ack_n(m_r_bus_1.ack),
                      .cmd_n(m_r_bus_1.cmd),
                      .addr_n(m_r_bus_1.addr)
                      );
           
//-------------MASTER_2-----------------------------
 //master_sequence_cmd
master_sequence_cmd # (
          .ADDR_WIDTH(ADDR_WIDTH),
          .MASTER_N(2)
          )
master_sequence_cmd_2 (
                      .rst(rst),
                      .clk(clk),
                      .data_accept(m_r_bus_2.resp), 
                      .master_N_cmd_rd_next(master_2_cmd_rd_next), 
                      .ack_n(m_r_bus_2.ack),
                      .cmd_n(m_r_bus_2.cmd),
                      .addr_n(m_r_bus_2.addr)
                      );
           
//-------------MASTER_3-----------------------------
 //master_sequence_cmd
master_sequence_cmd # (
          .ADDR_WIDTH(ADDR_WIDTH),
          .MASTER_N(3)
          )
master_sequence_cmd_3 (
                      .rst(rst),
                      .clk(clk),
                      .data_accept(m_r_bus_3.resp), 
                      .master_N_cmd_rd_next(master_3_cmd_rd_next), 
                      .ack_n(m_r_bus_3.ack),
                      .cmd_n(m_r_bus_3.cmd),
                      .addr_n(m_r_bus_3.addr)
                      );
           


// //---------SLAVE_0-------------
 //round-robin for SLAVE
 round_robin # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .SLAVE_N(0)
          )
round_robin_0 (
          .rst(rst),
          .clk(clk),
          .data_in_buf_router(data_in_buf_router_0),
          .addr_in_buf_router(addr_in_buf_router_0),
          .resp(resp_0),
          .m_r_bus_0(m0_s0_bus),//шина Master_0 <-> Router
          .m_r_bus_1(m1_s0_bus),//шина Master_1 <-> Router
          .m_r_bus_2(m2_s0_bus),//шина Master_2 <-> Router
          .m_r_bus_3(m3_s0_bus),//шина Master_3 <-> Router
          
          .r_s_bus_N(r_s_bus_0)//шина Router -> Slave_0
          );
          
//отправляет данные в Master согласно полученным ответам на запросы      
 round_robin_rd # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .SLAVE_N(0)
          )
round_robin_rd_0 (
          .rst(rst),
          .clk(clk),
          .data_in_buf_router(data_in_buf_router_0),
          .addr_in_buf_router(addr_in_buf_router_0),
          .resp(resp_0),
          .master_0_cmd_rd_next(master_0_cmd_rd_next),
          .master_1_cmd_rd_next(master_1_cmd_rd_next),
          .master_2_cmd_rd_next(master_2_cmd_rd_next),
          .master_3_cmd_rd_next(master_3_cmd_rd_next),
          .m_r_bus_0(m_r_bus_0_rd),//шина Master_0 <-> Router
          .m_r_bus_1(m_r_bus_1_rd),//шина Master_1 <-> Router
          .m_r_bus_2(m_r_bus_2_rd),//шина Master_2 <-> Router
          .m_r_bus_3(m_r_bus_3_rd)//шина Master_3 <-> Router 
          );
          

//------------------------------------------------------- 

// //---------SLAVE_1-------------
 //round-robin for SLAVE
 round_robin # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .SLAVE_N(1)
          )
round_robin_1 (
          .rst(rst),
          .clk(clk),
          .data_in_buf_router(data_in_buf_router_1),
          .addr_in_buf_router(addr_in_buf_router_1),
          .resp(resp_1),
          .m_r_bus_0(m0_s1_bus),//шина Master_0 <-> Router
          .m_r_bus_1(m1_s1_bus),//шина Master_1 <-> Router
          .m_r_bus_2(m2_s1_bus),//шина Master_2 <-> Router
          .m_r_bus_3(m3_s1_bus),//шина Master_3 <-> Router
          
          .r_s_bus_N(r_s_bus_1)//шина Router -> Slave_0
          );
          
//отправляет данные в Master согласно полученным ответам на запросы      
 round_robin_rd # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .SLAVE_N(1)
          )
round_robin_rd_1 (
          .rst(rst),
          .clk(clk),
          .data_in_buf_router(data_in_buf_router_1),
          .addr_in_buf_router(addr_in_buf_router_1),
          .resp(resp_1),
          .master_0_cmd_rd_next(master_0_cmd_rd_next),
          .master_1_cmd_rd_next(master_1_cmd_rd_next),
          .master_2_cmd_rd_next(master_2_cmd_rd_next),
          .master_3_cmd_rd_next(master_3_cmd_rd_next),
          .m_r_bus_0(m_r_bus_0_rd),//шина Master_0 <-> Router
          .m_r_bus_1(m_r_bus_1_rd),//шина Master_1 <-> Router
          .m_r_bus_2(m_r_bus_2_rd),//шина Master_2 <-> Router
          .m_r_bus_3(m_r_bus_3_rd)//шина Master_3 <-> Router
          );
          
//---------SLAVE_2-------------
 //round-robin for SLAVE
 round_robin # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .SLAVE_N(2)
          )
round_robin_2 (
          .rst(rst),
          .clk(clk),
          .data_in_buf_router(data_in_buf_router_2),
          .addr_in_buf_router(addr_in_buf_router_2),
          .resp(resp_2),
          .m_r_bus_0(m0_s2_bus),//шина Master_0 <-> Router
          .m_r_bus_1(m1_s2_bus),//шина Master_1 <-> Router
          .m_r_bus_2(m2_s2_bus),//шина Master_2 <-> Router
          .m_r_bus_3(m3_s2_bus),//шина Master_3 <-> Router
          
          .r_s_bus_N(r_s_bus_2)//шина Router -> Slave_2
          );
          
//отправляет данные в Master согласно полученным ответам на запросы      
 round_robin_rd # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .SLAVE_N(2)
          )
round_robin_rd_2 (
          .rst(rst),
          .clk(clk),
          .data_in_buf_router(data_in_buf_router_2),
          .addr_in_buf_router(addr_in_buf_router_2),
          .resp(resp_2),
          .master_0_cmd_rd_next(master_0_cmd_rd_next),
          .master_1_cmd_rd_next(master_1_cmd_rd_next),
          .master_2_cmd_rd_next(master_2_cmd_rd_next),
          .master_3_cmd_rd_next(master_3_cmd_rd_next),
          .m_r_bus_0(m_r_bus_0_rd),//шина Master_0 <-> Router
          .m_r_bus_1(m_r_bus_1_rd),//шина Master_1 <-> Router
          .m_r_bus_2(m_r_bus_2_rd),//шина Master_2 <-> Router
          .m_r_bus_3(m_r_bus_3_rd)//шина Master_3 <-> Router
          );

//---------SLAVE_3-------------
 //round-robin for SLAVE
 round_robin # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .SLAVE_N(3)
          )
round_robin_3 (
          .rst(rst),
          .clk(clk),
          .data_in_buf_router(data_in_buf_router_3),
          .addr_in_buf_router(addr_in_buf_router_3),
          .resp(resp_3),
          .m_r_bus_0(m0_s3_bus),//шина Master_0 <-> Router
          .m_r_bus_1(m1_s3_bus),//шина Master_1 <-> Router
          .m_r_bus_2(m2_s3_bus),//шина Master_2 <-> Router
          .m_r_bus_3(m3_s3_bus),//шина Master_3 <-> Router
          
          .r_s_bus_N(r_s_bus_3)//шина Router -> Slave_3
          );
          
//отправляет данные в Master согласно полученным ответам на запросы      
 round_robin_rd # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .SLAVE_N(3)
          )
round_robin_rd_3 (
          .rst(rst),
          .clk(clk),
          .data_in_buf_router(data_in_buf_router_3),
          .addr_in_buf_router(addr_in_buf_router_3),
          .resp(resp_3),
          .master_0_cmd_rd_next(master_0_cmd_rd_next),
          .master_1_cmd_rd_next(master_1_cmd_rd_next),
          .master_2_cmd_rd_next(master_2_cmd_rd_next),
          .master_3_cmd_rd_next(master_3_cmd_rd_next),
          .m_r_bus_0(m_r_bus_0_rd),//шина Master_0 <-> Router
          .m_r_bus_1(m_r_bus_1_rd),//шина Master_1 <-> Router
          .m_r_bus_2(m_r_bus_2_rd),//шина Master_2 <-> Router
          .m_r_bus_3(m_r_bus_3_rd) //шина Master_3 <-> Router
          );
//------------------------------------------------------- 

  
endmodule