`timescale 1 ns / 1 ps
//  timeunit 1ns;	
//  timeprecision 1ps;          
  

module round_robin_rd # (
              parameter DATA_WIDTH = 32,
              parameter ADDR_WIDTH = 32,
              parameter SLAVE_N = 0
            )
              (
                input logic rst,
                input logic clk,
                
                input logic [DATA_WIDTH-1:0] data_in_buf_router,
                input logic [6:0] addr_in_buf_router, //�� ����� ������ ������ ����� �� SLAVE_N
                input logic resp,
                
                input logic [6:0] master_0_cmd_rd_next, //����� ����� SLAVE ������ ���� ��������� � Master_0
                input logic [6:0] master_1_cmd_rd_next, //����� ����� SLAVE ������ ���� ��������� � Master_1
                input logic [6:0] master_2_cmd_rd_next, //����� ����� SLAVE ������ ���� ��������� � Master_2
                input logic [6:0] master_3_cmd_rd_next, //����� ����� SLAVE ������ ���� ��������� � Master_3
                
                master_slave_if.SLAVE   m_r_bus_0, //���� Master_0 -> Router
                master_slave_if.SLAVE   m_r_bus_1, //���� Master_1 -> Router
                master_slave_if.SLAVE   m_r_bus_2, //���� Master_2 -> Router
                master_slave_if.SLAVE   m_r_bus_3 //���� Master_3 -> Router 
              );
              
 logic [1:0] master_read_last_N; //����� �������, ����������� ����� ��������� �� Slave_N

 
// logic s_N_req;
// logic s_N_req_dd1;
//
// logic ack_dd1;
// logic get_d1;
// logic get_d2;
//


logic data_valid_in;
logic data_valid_out;
logic data_valid_out_dd1;
logic data_valid_out_dpram;
logic wr_en_dpram;
logic [6:0] addr_wr;
logic erase;
logic [6:0] addr_erase;
logic [6:0] addr_rd;
logic [6:0] addr_rd_dd1;
logic [6:0] addr_rd_dd2;
logic [DATA_WIDTH-1:0] data_wr;
logic [DATA_WIDTH-1:0] data_rd;
logic [2:0] cnt_check;
//---------�����_SLAVE_N-------------  
//dpram ��� �������� � ������� ������� �� SLAVE           
dpram #(
      .DATA_WIDTH(DATA_WIDTH+1),
      .ADDR_WIDTH(7)
      ) 
 dpram_slave_N (
            .clk(clk),
            .wr_en(wr_en_dpram),
            .data_in({data_valid_in, data_wr}),
            .addr_wr(addr_wr),
            .data_out({data_valid_out_dpram, data_rd}),
            .addr_rd(addr_rd)
            ); 
assign data_valid_out = (rst) ? 1'b0 : (data_valid_out_dpram) ? 1'b1 : 1'b0;           
//------------------------------------           


 //---------SLAVE-------------  
 //������������ ������
 always_ff @(posedge clk)
  begin
    if (rst)
      begin
        data_valid_out_dd1 <= 1'b0;
        addr_rd_dd1 <= 1'b0;
        addr_rd_dd2 <= 1'b0;
      end
    else 
      begin
        data_valid_out_dd1 <= data_valid_out;
        addr_rd_dd1 <= addr_rd;
        addr_rd_dd2 <= addr_rd_dd1;
      end
  end   


/*case ������������� ����������� ��������� � ���� Slave ���������� Master ������� �������� �� 
��������� ����� (round-robin). master_read_last_N ������ � ���� ����� ���������� MASTER ���������� ����� �� 
������ SLAVE. 
��� ��������� ��������� ��������� ������� (master_read_last_N+1) ������*/
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        master_read_last_N <= 3;
        addr_rd <= '0;
        cnt_check <= '0;
      end
    else if (!erase)
      begin
       case (master_read_last_N + 1'b1) //����� �������, ��� ������ ��� ��������� ��������� � Slave_0
        2'b00 : 
          begin
            if(master_0_cmd_rd_next[4:3] == SLAVE_N)
              begin
                addr_rd <= master_0_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 0;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 0;
                  end
              end
            else if(master_1_cmd_rd_next[4:3] == SLAVE_N)
              begin
                addr_rd <= master_1_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 1;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 1;
                  end
              end
            else if(master_2_cmd_rd_next[4:3] == SLAVE_N)
              begin
                addr_rd <= master_2_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 2;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 2;
                  end
              end
            else if(master_3_cmd_rd_next[4:3] == SLAVE_N)
              begin
                addr_rd <= master_3_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 3;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 3;
                  end
              end
          end
        2'b01 :
          begin
            if(master_1_cmd_rd_next[4:3] == SLAVE_N)
              begin
                addr_rd <= master_1_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 1;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 1;
                  end
              end
            else if(master_2_cmd_rd_next[4:3] == SLAVE_N) 
              begin
                addr_rd <= master_2_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 2;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 2;
                  end
              end
            else if(master_3_cmd_rd_next[4:3] == SLAVE_N)
              begin
                addr_rd <= master_3_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 3;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 3;
                  end
              end
            else if(master_0_cmd_rd_next[4:3] == SLAVE_N) 
              begin
                addr_rd <= master_0_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 0;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 0;
                  end
              end
          end
        2'b10 : 
          begin
            if(master_2_cmd_rd_next[4:3] == SLAVE_N)
              begin
                addr_rd <= master_2_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 2;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 2;
                  end
              end
            else if(master_3_cmd_rd_next[4:3] == SLAVE_N) 
              begin
                addr_rd <= master_3_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 3;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 3;
                  end
              end
            else if(master_0_cmd_rd_next[4:3] == SLAVE_N) 
              begin
                addr_rd <= master_0_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 0;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 0;
                  end
              end
            else if(master_1_cmd_rd_next[4:3] == SLAVE_N) 
              begin
                addr_rd <= master_1_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 1;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 1;
                  end
              end
          end
        2'b11 : 
          begin
            if(master_3_cmd_rd_next[4:3] == SLAVE_N)
              begin
                addr_rd <= master_3_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 3;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 3;
                  end
              end
            else if(master_0_cmd_rd_next[4:3] == SLAVE_N) 
              begin
                addr_rd <= master_0_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 0;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 0;
                  end
              end
            else if(master_1_cmd_rd_next[4:3] == SLAVE_N) 
              begin
                addr_rd <= master_1_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 1;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 1;
                  end
              end
            else if(master_2_cmd_rd_next[4:3] == SLAVE_N) 
              begin
                addr_rd <= master_2_cmd_rd_next;
                cnt_check <= cnt_check + 1;
                if ((cnt_check == 3) && !data_valid_out)
                  begin
                    master_read_last_N <= 2;
                    cnt_check <= '0;
                  end
                else if (cnt_check == 7)
                  begin
                    master_read_last_N <= 2;
                  end
              end
          end    
  //    default: 
  //      begin 
  //      end         
      endcase
    end
 end
 
// �������� ���������� ������ � ������ SLAVE � ���������� ������ �� ���� master <-> router
 always_ff @(posedge clk)
  begin
    if (rst)
      begin
        m_r_bus_0.rdata <= '0;
        m_r_bus_1.rdata <= '0;
        m_r_bus_2.rdata <= '0;
        m_r_bus_3.rdata <= '0;
        m_r_bus_0.resp <= 1'b0;
        m_r_bus_1.resp <= 1'b0;
        m_r_bus_2.resp <= 1'b0;
        m_r_bus_3.resp <= 1'b0;
        erase <= 1'b0;
        addr_erase <= '0;
      end
    //else if (data_valid_out && (addr_rd != addr_wr) && (addr_rd == addr_rd_dd1))
    else if (data_valid_out && (addr_rd == addr_rd_dd1))   
      begin
       case (addr_rd[6:5]) //����� ������� ���������� ����� �� SLAVE_N
        2'b00 : 
          begin
            m_r_bus_0.rdata <= data_rd;
            m_r_bus_0.resp <= 1'b1;
            erase <= 1'b1;
            addr_erase <= addr_rd;
          end
        2'b01 :
          begin
            m_r_bus_1.rdata <= data_rd;
            m_r_bus_1.resp <= 1'b1;
            erase <= 1'b1;
            addr_erase <= addr_rd;
          end
        2'b10 : 
          begin
            m_r_bus_2.rdata <= data_rd;
            m_r_bus_2.resp <= 1'b1;
            erase <= 1'b1;
            addr_erase <= addr_rd;
          end
        2'b11 : 
          begin
            m_r_bus_3.rdata <= data_rd;
            m_r_bus_3.resp <= 1'b1;
            erase <= 1'b1;
            addr_erase <= addr_rd;
          end    
//            default: 
//              begin
//                
//              end         
        endcase
      end
    else if (!data_valid_out && data_valid_out_dd1)
      begin
        case (addr_rd[6:5]) //����� ������� ���������� ����� �� SLAVE_N
          2'b00 : 
            begin
              m_r_bus_0.resp <= 1'b0;
            end
          2'b01 :
            begin
               m_r_bus_1.resp <= 1'b0;
            end
          2'b10 : 
            begin
              m_r_bus_2.resp <= 1'b0;
            end
          2'b11 : 
            begin
              m_r_bus_3.resp <= 1'b0;
            end    
  //            default: 
  //              begin
  //                
  //              end
        endcase
        erase <= 1'b0;
//          end
      end
 end

/*�� ������� Resp ����������� ������ �� SLAVE. 
������ ������������ �������, ������� ����� � ���� ���������� ��� ������ ������� ��� �����.
����� ����� �� FIFO.*/
always_ff @(posedge clk)
  begin
    if (rst)
      begin
        data_wr <= '0;
        addr_wr <= '0;
        data_valid_in  <= 1'b0;
        wr_en_dpram <= 1'b0;
      end
    else if (resp) 
      begin
        data_wr <= data_in_buf_router;
        addr_wr <= addr_in_buf_router;
        data_valid_in <= 1'b1;
        wr_en_dpram <= 1'b1;
      end
    else if (erase)
      begin
        data_valid_in <= 1'b0;
        addr_wr <= addr_erase;
        wr_en_dpram <= 1'b1;
      end
    else
      begin
        wr_en_dpram <= 1'b0;
      end
      
  end
//-------------------------------------------------------   
endmodule