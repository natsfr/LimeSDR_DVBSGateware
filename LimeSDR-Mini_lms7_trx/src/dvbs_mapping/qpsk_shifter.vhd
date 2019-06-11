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
	q_out: out std_logic_vector(11 downto 0)
	);
end QPSK_Shifter;

architecture arch of QPSK_Shifter is
	signal shifted_sym: std_logic_vector(47 downto 0);
	alias sym_current: std_logic_vector(1 downto 0) is shifted_sym(1 downto 0);
begin

	shifted_sym <= std_logic_vector(shift_right(unsigned(sym_in), to_integer(cnt_in*2)));

	with sym_current select
		i_out <= std_logic_vector(to_signed(1447, 12)) when "00",
			     std_logic_vector(to_signed(1447, 12)) when "01",
			     std_logic_vector(to_signed(-1447, 12)) when "10",
			     std_logic_vector(to_signed(-1447, 12)) when "11";

	with sym_current select
		q_out <= std_logic_vector(to_signed(1447, 12)) when "00",
			     std_logic_vector(to_signed(-1447, 12)) when "01",
			     std_logic_vector(to_signed(1447, 12)) when "10",
			     std_logic_vector(to_signed(-1447, 12)) when "11";

end arch;