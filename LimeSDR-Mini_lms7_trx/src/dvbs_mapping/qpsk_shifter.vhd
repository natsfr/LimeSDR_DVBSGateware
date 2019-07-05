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
use work.general_pkg.all;

entity QPSK_Shifter is
port (
	sym_in: in std_logic_vector(47 downto 0);
	cnt_in: in unsigned(6 downto 0);

	i_out: out std_logic_vector(11 downto 0);
	q_out: out std_logic_vector(11 downto 0);
	
	pskmod: in std_logic_vector(1 downto 0);
	sym_pi4: in signed(11 downto 0);
	sym_pi2: in signed(11 downto 0)
	);
end QPSK_Shifter;

architecture arch of QPSK_Shifter is
	signal shifted_sym: std_logic_vector(47 downto 0);
	alias qpsk_sym_current: std_logic_vector(1 downto 0) is shifted_sym(1 downto 0);
	alias psk8_sym_current: std_logic_vector(2 downto 0) is shifted_sym(2 downto 0);
	
	signal shift_index: integer range 1 to 3;
begin

	with pskmod select
		shift_index <= 3 when "01",
							2 when others;

	shifted_sym <= std_logic_vector(shift_right(unsigned(sym_in), to_integer(cnt_in*shift_index)));
				  
	process (psk8_sym_current, qpsk_sym_current, pskmod) is
	begin
		if pskmod = "01" then -- 8PSK
			case psk8_sym_current is
				when "000" =>
					i_out <= std_logic_vector(sym_pi4);
					q_out <= std_logic_vector(sym_pi4);
					
				when "001" =>
					i_out <= std_logic_vector(sym_pi2);
					q_out <= std_logic_vector(to_signed(0, 12));
					
				when "010" =>
					i_out <= std_logic_vector(-sym_pi2);
					q_out <= std_logic_vector(to_signed(0, 12));
					
				when "011" =>
					i_out <= std_logic_vector(-sym_pi4);
					q_out <= std_logic_vector(-sym_pi4);
					
				when "100" =>
					i_out <= std_logic_vector(to_signed(0, 12));
					q_out <= std_logic_vector(sym_pi2);
					
				when "101" =>
					i_out <= std_logic_vector(sym_pi4);
					q_out <= std_logic_vector(-sym_pi4);
					
				when "110" =>
					i_out <= std_logic_vector(-sym_pi4);
					q_out <= std_logic_vector(sym_pi4);
					
				when "111" =>
					i_out <= std_logic_vector(to_signed(0, 12));
					q_out <= std_logic_vector(-sym_pi2);
					
			end case;
		else -- QPSK
			case qpsk_sym_current is
				when "00" =>
					i_out <= std_logic_vector(sym_pi4);
					q_out <= std_logic_vector(sym_pi4);
					
				when "01" =>
					i_out <= std_logic_vector(sym_pi4);
					q_out <= std_logic_vector(-sym_pi4);
					
				when "10" =>
					i_out <= std_logic_vector(-sym_pi4);
					q_out <= std_logic_vector(sym_pi4);
					
				when "11" =>
					i_out <= std_logic_vector(-sym_pi4);
					q_out <= std_logic_vector(-sym_pi4);
					
			end case;
		end if;
	end process;

end arch;