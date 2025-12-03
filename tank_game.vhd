library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.tank_components.all;
use IEEE.numeric_std.all;

library work;
use work.tank_components.all;  

entity tank_game is
	port(
		clk_50 : in std_logic;
		global_reset : in std_logic;
		
		-- led_out : out std_logic;
		-- vga outputs
		vga_red, vga_green, vga_blue : out std_logic_vector(7 downto 0);
		horiz_sync, vert_sync, vga_blank, vga_clk : out std_logic;

		-- ps2 keyboard inputs
        ps2_clk  : in  std_logic;
        ps2_data : in  std_logic;
        kb_leds   : out std_logic_vector(3 downto 0)  -- [3]=A, [2]=S, [1]=K, [0]=L

		--scan code debug outputs
		--HEX0 : out std_logic_vector(6 downto 0);
		--HEX1 : out std_logic_vector(6 downto 0)
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
			speed : in std_logic;
			
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
	

	component ps2 is
		port(
			keyboard_clk, keyboard_data, clock_50MHz,
			reset : in std_logic;
			scan_code    : out std_logic_vector(7 downto 0);
			scan_readyo  : out std_logic;
			hist3        : out std_logic_vector(7 downto 0);
			hist2        : out std_logic_vector(7 downto 0);
			hist1        : out std_logic_vector(7 downto 0);
			hist0        : out std_logic_vector(7 downto 0);

			-- NEW: key state outputs (1 = currently pressed)
			key_A        : out std_logic;
			key_S        : out std_logic;
			key_K        : out std_logic;
			key_L        : out std_logic;

			-- single 7-seg HEX display (keep pin planning simple)
			hex0         : out std_logic_vector(6 downto 0)
		);
	end component;

    -- ps2 outputs
    signal ps2_scan_code   : std_logic_vector(7 downto 0);
    signal ps2_scan_ready  : std_logic;
    signal ps2_hist3       : std_logic_vector(7 downto 0);
    signal ps2_hist2       : std_logic_vector(7 downto 0);
    signal ps2_hist1       : std_logic_vector(7 downto 0);
    signal ps2_hist0       : std_logic_vector(7 downto 0);
    signal ps2_key_A       : std_logic;
    signal ps2_key_S       : std_logic;
    signal ps2_key_K       : std_logic;
    signal ps2_key_L       : std_logic;
    signal ps2_hex0        : std_logic_vector(6 downto 0);

	-- internal wires for keyboard_control
    signal kb_t1_speed : std_logic_vector(1 downto 0);
    signal kb_t1_fire  : std_logic;
    signal kb_t2_speed : std_logic_vector(1 downto 0);
    signal kb_t2_fire  : std_logic;
    signal kb_led_sig  : std_logic_vector(3 downto 0) := (others => '0');
	signal kb_hex0    : std_logic_vector(6 downto 0);
	signal kb_hex1    : std_logic_vector(6 downto 0);

	-- temporary tank 1 signals
	signal tank1x : unsigned(9 downto 0) := to_unsigned(240, 10);
	signal tank1y : unsigned(9 downto 0) := to_unsigned(100, 10);
	signal tank1spd : std_logic := '0';

	-- temporary tank 2 signals
	signal tank2x : unsigned(9 downto 0) := to_unsigned(240, 10);
	signal tank2y : unsigned(9 downto 0) := to_unsigned(400, 10);
	signal tank2spd : std_logic := '0';
	
	-- counter pulse
	signal counter_pulse : std_logic := '0';

	--ps2 reset is opposite of global reset
	signal ps2_reset : std_logic;

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
	--tank2x <= to_unsigned(240, 10);
	--tank2y <= to_unsigned(400, 10);

	--640×480, top left corner is (0,0)
	tank1 : tank
		generic map(
			x_start => 400,
			y_start => 40,
			tank_size => 40
		)
		port map(
			-- inputs
			clk => counter_pulse,
			rst => global_reset,
			speed => tank1spd,
			x_out => tank1x,
			y_out => tank1y
		);

	tank2 : tank
		generic map(
			x_start => 400,
			y_start => 360,
			tank_size => 40
		)
		port map(
			-- inputs
			clk => counter_pulse,
			rst => global_reset,
			speed => tank2spd,
			x_out => tank2x,
			y_out => tank2y
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

	 kb_ps2 : ps2
        port map(
            keyboard_clk  => ps2_clk,
            keyboard_data => ps2_data,
            clock_50MHz   => clk_50,
            reset         => ps2_reset,

            scan_code     => ps2_scan_code,
            scan_readyo   => ps2_scan_ready,
            hist3         => ps2_hist3,
            hist2         => ps2_hist2,
            hist1         => ps2_hist1,
            hist0         => ps2_hist0,

            key_A         => ps2_key_A,
            key_S         => tank1spd,
            key_K         => ps2_key_K,
            key_L         => tank2spd,

            hex0          => ps2_hex0
        );
		ps2_reset <= not global_reset;
		kb_leds(3) <= ps2_key_A;
		kb_leds(2) <= ps2_key_S;
		kb_leds(1) <= ps2_key_K;
		kb_leds(0) <= ps2_key_L;

end architecture structural;