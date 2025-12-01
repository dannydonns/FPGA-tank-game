library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.tank_components.all;
use IEEE.numeric_std.all;

entity tank_game is
	port(
		clk_50 : in std_logic;
		global_reset : in std_logic;
		
		-- led_out : out std_logic;
		-- vga outputs
		vga_red, vga_green, vga_blue : out std_logic_vector(7 downto 0);
		horiz_sync, vert_sync, vga_blank, vga_clk : out std_logic
	);
end entity tank_game;

architecture structural of tank_game is

	component counter is 
		generic(
			max_count : natural := 50000000
		);
		port(
			clk : in std_logic;
			rst : in std_logic;
			pulse_out : out std_logic
		);
	end component counter;

	component tank is
		generic(
			x_start, y_start : natural;
			tank_size : natural
		);
		port(
			-- inputs
			clk, rst : in std_logic;
			speed : in std_logic_vector(1 downto 0);
			
			-- coordinate outputs
			x_out, y_out : out unsigned(9 downto 0)
		);
	end component tank;

	-- vga componeent
	component vga_top_level is
		port(
    	    -- clock/reset inputs
    	    clock_50, reset_N : in std_logic;

    	    -- tank1 inputs
    	    tank1_x, tank1_y : in std_logic_vector(9 downto 0);

    	    -- tank2 inputs
    	    tank2_x, tank2_y : in std_logic_vector(9 downto 0);

    	    -- vga
    	    vga_red, vga_green, vga_blue    : out std_logic_vector(7 downto 0);
    	    horiz_sync, vert_sync, vga_blank, vga_clk : out std_logic
    	);
	end component vga_top_level;
	
	-- temporary tank 1 signals
	signal tank1x : unsigned(9 downto 0) := to_unsigned(240, 10);
	signal tank1y : unsigned(9 downto 0) := to_unsigned(100, 10);

	-- temporary tank 2 signals
	signal tank2x : unsigned(9 downto 0) := to_unsigned(240, 10);
	signal tank2y : unsigned(9 downto 0) := to_unsigned(400, 10);
	
	-- counter pulse
	signal counter_pulse : std_logic := '0';
begin

	game_cnt : counter
		generic map(
			max_count => 500000
		)
		port map(
			clk => clk_50,
			rst => global_reset,

			pulse_out => counter_pulse
		);
	-- tank1x <= to_unsigned(320, 10);
	-- tank1y <= to_unsigned(80, 10);
	tank2x <= to_unsigned(240, 10);
	tank2y <= to_unsigned(400, 10);

	tank1 : tank
		generic map(
			x_start => 320,
			y_start => 80,
			tank_size => 20
		)
		port map(
			-- inputs
			clk => counter_pulse,
			rst => global_reset,
			speed => "00",
			x_out => tank1x,
			y_out => tank1y
		);

	vga_top : vga_top_level
		port map(
			-- clock stuff
			clock_50 => clk_50,
			reset_N => global_reset,
			
			-- tank coordinates
			tank1_x => std_logic_vector(tank1x),
			tank1_y => std_logic_vector(tank1y),
			tank2_x => std_logic_vector(tank2x),
			tank2_y => std_logic_vector(tank2y),

			-- color stuff
			vga_red => vga_red,
			vga_green => vga_green,
			vga_blue => vga_blue, 

			-- clock synchronization stuff
			horiz_sync => horiz_sync,
			vert_sync => vert_sync,
			vga_blank => vga_blank,
			vga_clk => vga_clk
		);

end architecture structural;