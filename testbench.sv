module testbench;
  timeunit 1ns;	
  timeprecision 1ps;
 
  bit reset;
  bit clock;

  parameter PERIOD = 15.625;
  parameter DATA_WIDTH = 32;   
  parameter ADDR_WIDTH = 32; 
  
  master_slave_if m_s_bus_debug();
                                
 // F = 64 ÌÃö
  initial 
	  begin
		  clock = 1'b1;
			forever # (PERIOD/2) clock = !clock; 
		end
		
	initial 
	  begin
	    
		  reset = 1;
		  # (PERIOD*3);
		  reset = 0;
		end
initial
  begin
    m_s_bus_debug.ack = 0;
  end
  


router_top # (
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
          )
router_top_inst (
          .rst(reset),
          .clk(clock)
          );
              
endmodule






