`ifndef master_slave_IF // if the already-compiled flag is not set...
`define master_slave_IF // set the flag

interface master_slave_if 
  #(parameter byte DATA_WIDTH = 32, 
    parameter byte ADDR_WIDTH = 32
  )
  ();

logic                  req; // ������ �� ���������� ����������
logic [ADDR_WIDTH-1:0] addr; // ����� �������
logic                  cmd; // ��� ��������: 0 - read, 1 - write
logic [DATA_WIDTH-1:0] wdata; // ������������ ������. 
                              //���������� � ��� �� �����, ��� � �����.
logic 	      				 ack; 	/* C�����-�������������. Slave � ������ ����� ������ ������ � ����������, 
                              ������������ _addr, _cmd, � _wdata (� ������ ���������� ������). 
                              ������� _ack � �������� ��������� ��������� Master-���������� ����� ������ � ��������� �����.*/
logic [DATA_WIDTH-1:0] rdata; // ����������� ������
logic                  resp;  // ������-������������� ����������� ������ _rdata. 
                              //������ _rdata ������������ � �����, ����� ������� ������ ������. 

modport MASTER (output req, addr, cmd, wdata, input ack, rdata, resp);
modport SLAVE (output ack, rdata, resp, input  req, addr, cmd, wdata);     

endinterface : master_slave_if

`endif