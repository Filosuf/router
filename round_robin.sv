`timescale 1 ns / 1 ps
//  timeunit 1ns;	
//  timeprecision 1ps;          
  

module round_robin # (
              parameter DATA_WIDTH = 32,
              parameter ADDR_WIDTH = 32,
              parameter SLAVE_N = 0
            )
              (
                input logic rst,
                input logic clk,
                
                output logic [DATA_WIDTH-1:0] data_in_buf_router,
                output logic [6:0] addr_in_buf_router,
                output logic resp,
                
                master_slave_if.SLAVE   m_r_bus_0, //шина Master_0 -> Router
                master_slave_if.SLAVE   m_r_bus_1, //шина Master_1 -> Router
                master_slave_if.SLAVE   m_r_bus_2, //шина Master_2 -> Router
                master_slave_if.SLAVE   m_r_bus_3, //шина Master_3 -> Router
                
                master_slave_if.MASTER  r_s_bus_N //шина Router -> Slave_N
              );
              
 logic [1:0] m_n_req_last_N; //номер мастера, чей запрос был отправлен последним в Slave_N
 logic [1:0] slave_n;
 
 logic s_N_req;
 logic s_N_req_dd1;

 logic ack_dd1;
 logic get_d1;
 logic get_d2;

 logic [6:0] addr_cmd;
 logic [2:0] master_n_cmd_N [3:0];// запросы принятые от одного мастера и в один slave
 
 fifo_if fifo_bus ();
 
 fifo # (
          .DATA_WIDTH(ADDR_WIDTH),
          .FIFO_SIZE_EXP(3)
          )
fifo_route_slave_N (
                    .rst(rst),
                    .clk(clk),
                    .fifo_bus(fifo_bus)
                    );
            
 
 //---------SLAVE_0-------------
 
 assign slave_n = SLAVE_N;
 
 //формирование строба
 always_ff @(posedge clk)
  begin
    if (rst)
      begin
        ack_dd1 <= 1'b1;
        s_N_req_dd1 <= '0;
        get_d1 <= '0;
        get_d2 <= '0;
      end
    else 
      begin
        ack_dd1 <= r_s_bus_N.ack;
        s_N_req_dd1 <= s_N_req;
        get_d1 <= fifo_bus.get;
        get_d2 <= get_d1;
      end
  end
  
//Проверка на наличие запросов в Slave_0
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        s_N_req <= '0;
      end
    else if (r_s_bus_N.ack && !ack_dd1)
      begin
        s_N_req <= '0;
      end
    else
      begin
       s_N_req <= (m_r_bus_0.req && (m_r_bus_0.addr[31:30] == SLAVE_N)) ||  
                   (m_r_bus_1.req && (m_r_bus_1.addr[31:30] == SLAVE_N)) ||
                   (m_r_bus_2.req && (m_r_bus_2.addr[31:30] == SLAVE_N)) ||
                   (m_r_bus_3.req && (m_r_bus_3.addr[31:30] == SLAVE_N));
//       s_N_req <= (m_r_bus_0.req && (m_r_bus_0.addr[31:30] == SLAVE_N));
      end
  end
    


/*case устанавливает очередность обращений в один Slave нескольких Master методом перебора по 
круговому циклу (round-robin). m_n_req_last_N хранит в себе номер последнего отправившего запрос мастера. 
При следующем обращении приоритет получит (m_n_req_last_N+1) Мастер*/
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        m_n_req_last_N <= 3;
      end
    else
      begin
        if (s_N_req && !s_N_req_dd1)
          begin
             case (m_n_req_last_N + 1'b1) //номер мастера, чей запрос был отправлен последним в Slave_0
              2'b00 : 
                begin
                  if(m_r_bus_0.req && (m_r_bus_0.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 0;
                    end
                  else if(m_r_bus_1.req && (m_r_bus_1.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 1;
                    end
                  else if(m_r_bus_2.req && (m_r_bus_2.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 2;
                    end
                  else if(m_r_bus_3.req && (m_r_bus_3.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 3;
                    end
                end
              2'b01 :
                begin
                  if(m_r_bus_1.req && (m_r_bus_1.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 1;
                    end
                  else if(m_r_bus_2.req && (m_r_bus_2.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 2;
                    end
                  else if(m_r_bus_3.req && (m_r_bus_3.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 3;
                    end
                  else if(m_r_bus_0.req && (m_r_bus_0.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 0;
                    end
                end
              2'b10 : 
                begin
                  if(m_r_bus_2.req && (m_r_bus_2.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 2;
                    end
                  else if(m_r_bus_3.req && (m_r_bus_3.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 3;
                    end
                  else if(m_r_bus_0.req && (m_r_bus_0.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 0;
                    end
                  else if(m_r_bus_1.req && (m_r_bus_1.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 1;
                    end
                end
              2'b11 : 
                begin
                  if(m_r_bus_3.req && (m_r_bus_3.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 3;
                    end
                  else if(m_r_bus_0.req && (m_r_bus_0.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 0;
                    end
                  else if(m_r_bus_1.req && (m_r_bus_1.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 1;
                    end
                  else if(m_r_bus_2.req && (m_r_bus_2.addr[31:30] == SLAVE_N))
                    begin
                      m_n_req_last_N <= 2;
                    end
                end    
  //            default: 
  //              begin 
  //              end         
            endcase
          end
      end
 end

assign addr_cmd = {m_n_req_last_N, slave_n, master_n_cmd_N[m_n_req_last_N]};   //[x : 0] master_n_cmd_N [m_n_req_last_N] - запросы принятые от одного мастера и в один slave
 
// ожидание ответа от SLAVE 
 always_ff @(posedge clk)
  begin
    if (rst)
      begin
        fifo_bus.data_in <= '0;
        fifo_bus.put <= 1'b0;
        master_n_cmd_N[0] <= '0;
        master_n_cmd_N[1] <= '0;
        master_n_cmd_N[2] <= '0;
        master_n_cmd_N[3] <= '0;
      end
    else
      begin
       case (m_n_req_last_N) //номер мастера, чей запрос был отправлен последним в Slave_0
        2'b00 : 
          begin
            if(r_s_bus_N.ack && !ack_dd1 && !r_s_bus_N.cmd && !fifo_bus.full)
              begin  
                fifo_bus.data_in <= addr_cmd;
                fifo_bus.put <= 1'b1;
                //master_n_cmd_N[m_n_req_last_N] <= master_n_cmd_N[m_n_req_last_N] + 1;
                master_n_cmd_N[0] <= master_n_cmd_N[0] + 1;
              end
            else
              begin
                fifo_bus.put <= 1'b0;
              end
          end
        2'b01 :
          begin
            if(r_s_bus_N.ack && !ack_dd1 && !r_s_bus_N.cmd && !fifo_bus.full)
              begin  
                fifo_bus.data_in <= addr_cmd;
                fifo_bus.put <= 1'b1;
                //master_n_cmd_N[m_n_req_last_N] <= master_n_cmd_N[m_n_req_last_N] + 1;
                master_n_cmd_N[1] <= master_n_cmd_N[1] + 1;
              end
            else
              begin
                fifo_bus.put <= 1'b0;
              end
          end
        2'b10 : 
          begin
            if(r_s_bus_N.ack && !ack_dd1 && !r_s_bus_N.cmd && !fifo_bus.full)
              begin  
                fifo_bus.data_in <= addr_cmd;
                fifo_bus.put <= 1'b1;
                //master_n_cmd_N[m_n_req_last_N] <= master_n_cmd_N[m_n_req_last_N] + 1;
                master_n_cmd_N[2] <= master_n_cmd_N[2] + 1;
              end
            else
              begin
                fifo_bus.put <= 1'b0;
              end
          end
        2'b11 : 
          begin
            if(r_s_bus_N.ack && !ack_dd1 && !r_s_bus_N.cmd && !fifo_bus.full)
              begin  
                fifo_bus.data_in <= addr_cmd;
                fifo_bus.put <= 1'b1;
                //master_n_cmd_N[m_n_req_last_N] <= master_n_cmd_N[m_n_req_last_N] + 1;
                master_n_cmd_N[3] <= master_n_cmd_N[3] + 1;
              end
            else
              begin
                fifo_bus.put <= 1'b0;
              end
          end    
//            default: 
//              begin
//                
//              end         
            endcase
//          end
      end
 end

/*по сигналу Resp защелкиваем данные от SLAVE. 
Данные сопровождаем адресом, который несет в себе информацию для какого мастера это ответ.
Адрес берем из FIFO.*/
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        fifo_bus.get <= '0;
        data_in_buf_router <= '0;
      end
    else if (r_s_bus_N.resp && !fifo_bus.empty) 
      begin
        data_in_buf_router <= r_s_bus_N.rdata;
        fifo_bus.get <= 1'b1;
      end
    else
      begin
        fifo_bus.get <= 1'b0;
      end
  end
// выставляем адресс  
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        addr_in_buf_router <= '0;
        resp <= '0;
      end
    else if (get_d1 && !get_d2) 
      begin
        addr_in_buf_router <= fifo_bus.data_out;
        resp <= 1'b1; 
      end
    else
      begin
        resp <= 1'b0;
      end
  end
  
  
// ожидание ответа от SLAVE 
 always_ff @(posedge clk)
  begin
    if (rst)
      begin
        r_s_bus_N.req   <= '0; //обнуление для исключения 3-х состояний
        r_s_bus_N.addr  <= '0;
        r_s_bus_N.cmd   <= '0;
        r_s_bus_N.wdata <= '0;
        m_r_bus_0.ack   <= '1;
        m_r_bus_1.ack   <= '1;
        m_r_bus_2.ack   <= '1;
        m_r_bus_3.ack   <= '1;
      end
    else
      begin
       case (m_n_req_last_N) //номер мастера, чей запрос был отправлен последним в Slave_0
        2'b00 : 
          begin
              if(m_r_bus_0.addr[31:30] == SLAVE_N)
              begin
                r_s_bus_N.req   <= m_r_bus_0.req;
                r_s_bus_N.addr  <= m_r_bus_0.addr;
                r_s_bus_N.cmd   <= m_r_bus_0.cmd;
                r_s_bus_N.wdata <= m_r_bus_0.wdata;
                m_r_bus_0.ack   <= r_s_bus_N.ack;
              end
          end
        2'b01 :
          begin
            if (m_r_bus_1.addr[31:30] == SLAVE_N)
              begin;
                r_s_bus_N.req   <= m_r_bus_1.req;
                r_s_bus_N.addr  <= m_r_bus_1.addr;
                r_s_bus_N.cmd   <= m_r_bus_1.cmd;
                r_s_bus_N.wdata <= m_r_bus_1.wdata;
                m_r_bus_1.ack   <= r_s_bus_N.ack;
              end
          end
        2'b10 : 
          begin
            if (m_r_bus_2.addr[31:30] == SLAVE_N)  
              begin
                r_s_bus_N.req   <= m_r_bus_2.req;
                r_s_bus_N.addr  <= m_r_bus_2.addr;
                r_s_bus_N.cmd   <= m_r_bus_2.cmd;
                r_s_bus_N.wdata <= m_r_bus_2.wdata;
                m_r_bus_2.ack   <= r_s_bus_N.ack;
              end
          end
        2'b11 : 
          begin
            if (m_r_bus_3.addr[31:30] == SLAVE_N)
              begin
                r_s_bus_N.req   <= m_r_bus_3.req;
                r_s_bus_N.addr  <= m_r_bus_3.addr;
                r_s_bus_N.cmd   <= m_r_bus_3.cmd;
                r_s_bus_N.wdata <= m_r_bus_3.wdata;
                m_r_bus_3.ack   <= r_s_bus_N.ack;
              end
          end    
//            default: 
//              begin
//                
//              end         
            endcase
//          end
      end
 end
//-------------------------------------------------------   
endmodule