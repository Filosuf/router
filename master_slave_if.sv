`ifndef master_slave_IF // if the already-compiled flag is not set...
`define master_slave_IF // set the flag

interface master_slave_if 
  #(parameter byte DATA_WIDTH = 32, 
    parameter byte ADDR_WIDTH = 32
  )
  ();

logic                  req; // запрос на выполнение транзакции
logic [ADDR_WIDTH-1:0] addr; // адрес запроса
logic                  cmd; // Тип операции: 0 - read, 1 - write
logic [DATA_WIDTH-1:0] wdata; // Записываемые данные. 
                              //Передаются в том же такте, что и адрес.
logic 	      				 ack; 	/* Cигнал-подтверждение. Slave в данном такте принял запрос к исполнению, 
                              зафиксировав _addr, _cmd, и _wdata (в случае транзакции записи). 
                              Перевод _ack в активное состояние разрешает Master-устройству снять запрос в следующем такте.*/
logic [DATA_WIDTH-1:0] rdata; // Считываемые данные
logic                  resp;  // Сигнал-подтверждение считываемых данных _rdata. 
                              //Данные _rdata возвращаются в такте, когда активен данный сигнал. 

modport MASTER (output req, addr, cmd, wdata, input ack, rdata, resp);
modport SLAVE (output ack, rdata, resp, input  req, addr, cmd, wdata);     

endinterface : master_slave_if

`endif