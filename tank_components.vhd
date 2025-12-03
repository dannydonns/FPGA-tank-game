library IEEE;
use IEEE.std_logic_1164.all;


package tank_components is
	component counter is
		generic(
			max_count : natural
		);
		port(
			clk : in std_logic;
			rst : in std_logic;
			pulse_out : out std_logic
		);
	end component counter;

	constant tank_size_x : integer := 30;
	constant tank_size_y : integer := 80;

end package tank_components;

package body tank_components is

end package body tank_components;