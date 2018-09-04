`timescale 1 ns / 1 ps
//  timeunit 1ns;	
//  timeprecision 1ps;          
  

module slave # (
              parameter DATA_WIDTH = 32,
              parameter ADDR_WIDTH = 32
            )
              (
                input logic rst,
                input logic clk,
                
                master_slave_if.SLAVE  master_slave_bus 
              );                              
  
logic 	      				 ack; 	/* Cигнал-подтверждение. Slave в данном такте прин€л запрос к исполнению, 
                              зафиксировав _addr, _cmd, и _wdata (в случае транзакции записи). 
                              ѕеревод _ack в активное состо€ние разрешает Master-устройству сн€ть запрос в следующем такте.*/
logic [DATA_WIDTH-1:0] rdata; // —читываемые данные
logic                  resp;  // —игнал-подтверждение считываемых данных _rdata. 
                              //ƒанные _rdata возвращаютс€ в такте, когда активен данный сигнал. 


//---------SRAM---------------- 
logic nwe;
logic [DATA_WIDTH-1:0] data_in;
logic [DATA_WIDTH-1:0] data_out;
logic [ADDR_WIDTH-1:0] addr_wr;
logic [ADDR_WIDTH-1:0] addr_rd;
//---------SRAM--END--------------

logic req;
logic req_d1;
logic req_d2;
logic req_d3;
logic req_d4;
logic ack_d1;
logic put;
logic put_d1;
logic get_d1;

logic [4:0] cnt_rd;


fifo_if fifo_bus ();

assign master_slave_bus.ack = ack;
assign master_slave_bus.rdata = rdata;
assign master_slave_bus.resp = resp;
assign req = (rst) ? 1'b0 : master_slave_bus.req;
assign fifo_bus.put = put_d1;

dpram #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(15)
      ) 
 dpram_inst (
            .clk(clk),
            .wr_en(!nwe),
            .data_in(data_in),
            .addr_wr(addr_wr[14:0]),
            .data_out(data_out),
            .addr_rd(addr_rd[14:0])
            );

fifo # (
          .DATA_WIDTH(ADDR_WIDTH),
          .FIFO_SIZE_EXP(2)
          )
fifo_slave (
            .rst(rst),
            .clk(clk),
            .fifo_bus(fifo_bus)
            );
          
//задержка дл€ имитации не мгновенной работы SLAVE
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        req_d1 <= 1'b0;
        req_d2 <= 1'b0;
        req_d3 <= 1'b0;
        req_d4 <= 1'b0;
        ack_d1 <= 1'b0;
        put_d1 <= 1'b0;
        get_d1 <= 1'b0;
      end
    else
      begin
        req_d1 <= req;
        req_d2 <= req_d1;
        req_d3 <= req_d2;
        req_d4 <= req_d3;
        ack_d1 <= ack;
        put_d1 <= put;
        get_d1 <= fifo_bus.get;
      end
  end 
/*задержка дл€ увеличени€ времени ответов на запросы чтени€.
ƒл€ тестировани€ накоплени€ буфера (когда подр€д несколько запросов на чтение)
и дл€ тестировани€ роутера на секвенирование)*/
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        cnt_rd <= 1'b0;
      end
    else if (cnt_rd == 15)
      begin
        cnt_rd <= 1'b0;
      end
    else if ((fifo_bus.get && !get_d1) || (cnt_rd > 0))
      begin
        cnt_rd <= cnt_rd + 1;
      end
  end
  
//в буфер FIFO
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        fifo_bus.get <= '0;
      end
    else if (resp)
      begin
        fifo_bus.get <= 1'b0;
      end
    else if (!(req && !req_d2) || !master_slave_bus.cmd)//условие исключающее одновременное назначение put и get дл€ FIFO
      begin
        if (!fifo_bus.empty)//буфер FIFO не пустой
          begin
            fifo_bus.get <= 1'b1;
          end
      end    
  end

//„тение по записанным адресам в буфер FIFO
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        addr_rd <= '0;
        rdata <= '0;
        resp <= '0;
      end
    else if ((cnt_rd == 0) || (cnt_rd == 1))
      begin
        resp <= '0; // адрес из FIFO
      end
    else if (cnt_rd == 12)
      begin
        addr_rd <= fifo_bus.data_out; // адрес из FIFO
      end  
    else if (cnt_rd == 14)
      begin
        rdata <= data_out; // чтение данных из SLAVE
      end
    else if (cnt_rd == 15)
      begin
        resp <= 1'b1; // сигнал валидности данных
      end
  end          


//прием команд, запись данных при запросе на запись
//или запись адресов дл€ чтени€ в буфер FIFO
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        nwe <= 1'b1;
        addr_wr <= '0;
        data_in <= '0;
        ack <= 1'b1;
        //resp <= 1'b0;
        put <= 1'b0;
      end
    else if (req && !req_d1)//первым тактом сбрасываем ack
        begin
          //ack <= 1'b0;
          ack <= 1'b0;
         // resp <= 1'b0;
          put <= 1'b0;
        end
    else if (req && req_d1)//на второй такт адрес должен уже установитс€, можно начинать чтение/запись и выставить сигнал ack
      begin
        if (master_slave_bus.cmd)
            begin
              nwe <= 1'b0;
              addr_wr <= master_slave_bus.addr;
              data_in <= master_slave_bus.wdata;
              ack <= 1'b1;
            end
          else
            begin
              if (!fifo_bus.full)
                begin
                  nwe <= 1'b1;
                  put <= 1'b1;
                  if (put && !put_d1)
                    begin
                      fifo_bus.data_in <= master_slave_bus.addr;
                      ack <= 1'b1;
                    end
                end
            end
      end         
  end


  

//-------------------------------------------------------   
endmodule