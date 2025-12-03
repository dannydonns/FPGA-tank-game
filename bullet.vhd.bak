library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_numeric.all;

entity bullet is

	generic(
		size_x : natural : 5;
		size_y : natural : 20;
		direction : std_logic := 0 -- down (1), up (0)
	);

	port(
		-- inputs
		clk, rst : in std_logic;
		
		-- tank coordinates
		x_tank, y_tank : in unsigned(9 downto 0);
		
		-- fire signal
		fire : in std_logic;
		
		-- bullet outputs
		x_out, y_out : out unsigned(9 downto 0);

	);

end entity bullet;

architecture behavioral of bullet is

-- state is defined by: fired/not fired
-- default state is not fired
	signal curr_fired : std_logic := 0;
	
-- 

begin








end architecture behavioral;