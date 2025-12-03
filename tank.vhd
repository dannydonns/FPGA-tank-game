library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tank is
	generic(
		x_start, y_start : natural;
		tank_size : natural
	);
	port(
		-- inputs
		clk, rst : in std_logic;
		speed : in std_logic;
		
		-- coordinate outputs
		x_out, y_out : out unsigned(9 downto 0)
	);

end entity tank;

architecture behavioral of tank is 
	-- x, y signals
	signal x_curr : unsigned(9 downto 0) := to_unsigned(x_start, 10);
	signal x_nxt : unsigned(9 downto 0) := to_unsigned(x_start, 10);
	signal y_t : unsigned(9 downto 0) := to_unsigned(y_start, 10);
	
	
	-- state declaration
	signal dir_curr : std_logic := '0';
	signal dir_nxt : std_logic := '0';
	signal key_curr : std_logic := '0';	-- '0' is up, '1' is down
	signal key_nxt : std_logic := '0'; 	
	signal spd_curr : std_logic_vector(1 downto 0) := "00"; 
	signal spd_nxt : std_logic_vector(1 downto 0) := "00"; 
	
	function advance_tank(dir: std_logic; x : unsigned; spd: std_logic_vector(1 downto 0)) return unsigned is 
		variable x_adv : unsigned(9 downto 0);
	begin
		
		case spd is
			
			when "01" =>
				if(dir='0') then
					x_adv := x - 5;
				else
					x_adv := x + 5;
				end if;
			when "10" =>
				if(dir='0') then
					x_adv := x - 10;
				else
					x_adv := x + 10;
				end if;
			when others => 
				if(dir='0') then
					x_adv := x - 2;
				else
					x_adv := x + 2;
				end if;
		end case;
		
		return (x_adv);
	end function advance_tank;
	
begin
	y_out <= y_t;
	clk_process : process(clk, rst)
	begin
		if (rst = '1') then
			dir_curr <= '0';
			spd_curr <= "00";
			x_curr <= to_unsigned(x_start, 10);
			key_curr <= '0';
		elsif (rising_edge(clk)) then
			dir_curr <= dir_nxt;
			x_out <= x_nxt;
			x_curr <= x_nxt;
			spd_curr <= spd_nxt;		
			key_curr <= key_nxt;
		end if;
	end process clk_process;

	
	direction_process : process(x_curr, dir_curr, speed)
	begin
		-- left or right
		case dir_curr is
			when '0' =>
				if (x_curr < to_unsigned(tank_size, 10)) then
					-- switch directions and move in a different direction
					dir_nxt <= '1';
				else
					dir_nxt <= '0';
				end if;
			when '1' =>
				if (x_curr > to_unsigned(640 - tank_size, 10)) then
					dir_nxt <= '0';
				else
					dir_nxt <= '1';
				end if;
			when others =>
				dir_nxt <= '0';
		end case;
		

		
		if speed = '1' then
			case spd_curr is
				when "00" =>
					if (key_curr = '0') then
						spd_nxt <= "01";
					end if;
				when "01" =>
					if (key_curr = '0') then
						spd_nxt <= "10";
					end if;
				when others =>
					if (key_curr = '0') then
						spd_nxt <= "00";
					end if;
			end case;
		end if;
		key_nxt <= speed;

		x_nxt <= advance_tank(dir_curr, x_curr, spd_curr);
	end process direction_process;
	
end architecture behavioral;