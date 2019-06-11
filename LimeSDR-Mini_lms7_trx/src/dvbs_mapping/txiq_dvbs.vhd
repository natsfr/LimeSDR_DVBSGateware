-- ----------------------------------------------------------------------------	
-- FILE: txiq_dvbs.vhd
-- DESCRIPTION: Support packed symbols mode for DVBS 
-- DATE:	June 18, 2019
-- AUTHOR(s):	Mehdi Khairy F4IHX (nats) - Evariste Courjaud F5OEO
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fpgacfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity txiq_dvbs is
   generic( 
      dev_family	: string := "Cyclone IV E";
      iq_width		: integer := 12
   );
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      en          : in std_logic;
      --Mode settings
      trxiqpulse	: in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		: in std_logic; -- DDR: 1; SDR: 0
		mimo_en		: in std_logic; -- SISO: 1; MIMO: 0
		ch_en			: in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.  
		fidm			: in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Tx interface data 
      DIQ_h		 	: out std_logic_vector(iq_width downto 0);
		DIQ_l	 	   : out std_logic_vector(iq_width downto 0);
      --fifo ports 
      fifo_rdempty: in std_logic;
      fifo_rdreq  : out std_logic;
      fifo_q      : in std_logic_vector(iq_width*4-1 downto 0);
      --TX activity indication
      txant_en    : out std_logic;
		
		from_fpgacfg         : in     t_FROM_FPGACFG
        );
end txiq_dvbs;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of txiq_dvbs is
--declare signals,  components here
signal int_fifo_rdreq      : std_logic;
signal int_fifo_q_valid    : std_logic;

signal diq_L_reg_0         : std_logic_vector(iq_width downto 0);

signal diq_H_reg_0         : std_logic_vector(iq_width downto 0);

signal rd_wait_cnt         : unsigned(15 downto 0);
signal rd_wait_cnt_max     : unsigned(15 downto 0);
signal rd_wait_cnt_max_reg : unsigned(15 downto 0);

signal zero_valid          : std_logic;

type state_type is (idle, rd_samples);
signal current_state, next_state : state_type;

signal sig_i   				: std_logic_vector(11 downto 0);
signal sig_q   				: std_logic_vector(11 downto 0);
signal gated_fifo_data		: std_logic_vector(47 downto 0);
signal dyn_data				: std_logic_vector(47 downto 0);
signal cnt_data				: integer range 0 to 24;
signal cnt_sym					: integer range 0 to 3;
signal up_factor				: integer range 1 to 4;

begin

rd_wait_cnt_max <= to_unsigned(24 * up_factor, 16);
                     
fifo_rdreq <= int_fifo_rdreq AND NOT fifo_rdempty;

qpsk_shifter_inst : work.QPSK_Shifter
   port map (
      sym_in => gated_fifo_data,
      cnt_in => to_unsigned(cnt_data, 7),
      
      i_out => sig_i,
      q_out => sig_q
   );

fsm_sync: process(clk, reset_n) begin
   if reset_n = '0' then
      current_state <= idle;
      rd_wait_cnt <= (others=>'0');
		cnt_data <= 0;
		cnt_sym <= 0;
   elsif rising_edge(clk) then

      diq_H_reg_0 <= '0' & sig_i;
      diq_L_reg_0 <= '1' & sig_q;

      int_fifo_rdreq <= '0';

      txant_en <= '1';

      case current_state is
         when idle =>
            if fifo_rdempty = '0' AND en = '1' then 
                  current_state <= rd_samples;
            else 
               current_state <= idle;
            end if;
            diq_H_reg_0 <= "0" & (iq_width-1 downto 0  =>'0');
            diq_L_reg_0 <= "1" & (iq_width-1 downto 0  =>'0');
            txant_en <= '0';
				up_factor <= to_integer(unsigned(from_fpgacfg.dvbs_upsample));

         when rd_samples =>
            rd_wait_cnt <= rd_wait_cnt + 1;
				cnt_sym <= cnt_sym + 1;
				if cnt_sym = (up_factor - 1) then
					cnt_sym <= 0;
					cnt_data <= cnt_data + 1; -- Usable for upsample differentiation
					if rd_wait_cnt = rd_wait_cnt_max - 1 then
						rd_wait_cnt <= (others=>'0');
						cnt_data <= 0;
						if fifo_rdempty = '1' then
							current_state <= idle;
						else
							int_fifo_rdreq <= '1';
							gated_fifo_data <= fifo_q;
						end if;
					end if;
				else
					diq_H_reg_0 <= "0" & (iq_width-1 downto 0  =>'0');
					diq_L_reg_0 <= "1" & (iq_width-1 downto 0  =>'0');
				end if;
				
      end case;
   end if;
end process;
    
--To output ports   
DIQ_l <= diq_L_reg_0;
DIQ_h <= diq_H_reg_0; 
 
end arch;   


