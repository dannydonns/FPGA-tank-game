-- library IEEE;
-- use IEEE.std_logic_1164.all;

-- entity bullet is
	
-- 	generic(
-- 		x_start, y_start : natural;
-- 		bullet_size_x: natural;
-- 		bullet_size_y : natural
-- 	);

-- 	port(
-- 		clk, rst : in std_logic;
-- 		x_tank, y_tank : in unsigned(9 downto 0);
-- 		fire : in std_logic;
		
-- 		-- out
-- 		x_out, y_out : unsigned(9 downto 0)
-- 	);

-- end entity;


-- architecture behavioral of bullet is

-- 	-- state variables
-- 	signal x_curr : unsigned(9 downto 0) := to_unsigned(x_start, 10);
-- 	signal x_nxt : unsigned(9 downto 0) := to_unsigned(x_start, 10);
-- 	signal y_curr : unsigned(9 downto 0) := to_unsigned(y_start, 10);
-- 	signal y_nxt : unsigned(9 downto 0) := to_unsigned(y_start, 10);

-- 	-- fire state
-- 	signal fstate_curr : std_logic := '0'; -- '0' is reset, '1' is fired
-- 	signal fstate_nxt : std_logic := '0';

-- 	-- fire key state (prevent from constant holding down)
-- 	signal fkey_curr : std_logic := '0';
-- 	signal fkey_nxt : std_logic := '0';

-- begin
-- 	-- clock process
-- 	clk_prc : process(clk, rst)
-- 	begin
-- 		if (rst = '1') then
-- 			-- default state is that 
-- 			fstate_curr <= '0';
-- 			x_curr <= x_tank;
-- 			y_curr <= y_tank;
-- 			fkey_curr <= '0';

-- 		elsif (rising_edge(clk)) then
-- 			fstate_curr <= fstate_nxt;
-- 			x_curr <= x_nxt;
-- 			x_out <= x_curr;
-- 			y_curr <= y_nxt;
-- 			y_out <= y_curr;
-- 			fkey_curr <= fkey_nxt;

-- 		end if;
-- 	end process;

-- 	state_proc : process(fire, fstate_curr)
-- 	begin
-- 		case 

-- 		-- update fkey
-- 		fkey_nxt <= fire;
-- 	end process;
-- end architecture behavioral;