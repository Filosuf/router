`ifndef fifo_IF // if the already-compiled flag is not set...
`define fifo_IF // set the flag

interface fifo_if 
  #(parameter byte DATA_WIDTH = 32)
  ();
logic [DATA_WIDTH-1:0] data_in; // Записываемые данные.
logic [DATA_WIDTH-1:0] data_out; // Считываемые данные
logic                  put; // Положить в буфер
logic                  get; // Забрать из буффера
logic                  full; // Буфер полон
logic                  empty; // Буфер пуст 

modport SRC (output data_out, full, empty, input data_in, put, get);     

endinterface : fifo_if

`endif