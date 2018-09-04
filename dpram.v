module dpram (clk, wr_en, data_in, addr_rd, addr_wr, data_out);
  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 8;
  
  input clk, wr_en;
  input [DATA_WIDTH-1:0] data_in;
  input [ADDR_WIDTH-1:0] addr_rd, addr_wr;
  
  output reg [DATA_WIDTH-1:0] data_out;
  
  reg [DATA_WIDTH-1:0] ram [(2**ADDR_WIDTH)-1:0]; 
  reg [ADDR_WIDTH-1:0] addr_rd_d;
  
  always @(posedge clk)
    begin
      if (wr_en)
        ram[addr_wr] <= data_in;
      addr_rd_d <= addr_rd;
      data_out <= ram[addr_rd];
    end
endmodule