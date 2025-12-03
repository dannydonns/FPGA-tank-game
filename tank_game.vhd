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
        kb_leds   : out std_logic_vector(3 downto 0);  -- [3]=A, [2]=S, [1]=K, [0]=L

		--scan code debug outputs
		--HEX0 : out std_logic_vector(6 downto 0);
		--HEX1 : out std_logic_vector(6 downto 0)

		--led collision indicators
		led_hit_1_on_2 : out std_logic;
		led_hit_2_on_1 : out std_logic
	);
end entity tank_game;

architecture structural of tank_game is
	component pll IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC 
	);
	end component;

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

			--bullet1 inputs
			bullet1_x, bullet1_y : in std_logic_vector(9 downto 0);
			--bullet2 inputs
			bullet2_x, bullet2_y : in std_logic_vector(9 downto 0);

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
	
	--bullet component
	component bullet is
    generic(
        speed    : integer := 4;    -- pixels per tick
        screen_h : integer := 480   -- vertical resolution (e.g., 480)
    );
    port(
        clk       : in  std_logic;               -- game tick (e.g., counter_pulse)
        rst       : in  std_logic;               -- active-high reset

        fire      : in  std_logic;               -- fire button (e.g., ps2_key_S / ps2_key_L)
        direction : in  std_logic;               -- '0' = up, '1' = down

        tank_x    : in  unsigned(9 downto 0);    -- tank position at spawn time
        tank_y    : in  unsigned(9 downto 0);

        active    : out std_logic;               -- 1 if bullet on screen
        x_out     : out unsigned(9 downto 0);
        y_out     : out unsigned(9 downto 0)
    );
	end component;

	component collision is
    generic(
        tank_size_x   : natural := 40;
        tank_size_y   : natural := 40;
        bullet_size_x : natural := 2;
        bullet_size_y : natural := 4
    );
    port(
        -- bullet coords (top-left of bullet rect)
        x_bullet, y_bullet : in unsigned(9 downto 0);
        -- tank coords (top-left of tank rect)
        x_tank,  y_tank    : in unsigned(9 downto 0);
        -- 1 if rectangles overlap this cycle
        collision_signal   : out std_logic
    );
end component;

	--bullet signals
	signal bullet1_active : std_logic;
	signal bullet1x : unsigned(9 downto 0);
	signal bullet1y : unsigned(9 downto 0);
	signal bullet2_active : std_logic;
	signal bullet2x : unsigned(9 downto 0);
	signal bullet2y : unsigned(9 downto 0);

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
	signal key_A_raw : std_logic;
	signal key_S_raw : std_logic;
	signal key_K_raw : std_logic;
	signal key_L_raw : std_logic;

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

	-- pll clock
	signal clk_100 : std_logic;

	--collision signals
	signal hit_1_on_2 : std_logic;
	signal hit_2_on_1 : std_logic;

begin
	
	pll_inst : pll
	port map
	(
		inclk0	=> clk_50,
		c0		=> clk_100
	);

	game_cnt : counter
		generic map(
			max_count => 500000
		)
		port map(
			clk => clk_100,
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

	tank1spd <= key_S_raw;  -- S controls top tank
	tank2spd <= key_L_raw;  -- L controls bottom tank

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

			--bullet coordinates
			bullet1_x => std_logic_vector(bullet1x),
			bullet1_y => std_logic_vector(bullet1y),
			bullet2_x => std_logic_vector(bullet2x),
			bullet2_y => std_logic_vector(bullet2y),

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

	--bullet1 instance
	bullet1: bullet
    generic map(
        speed => 10,    -- pixels per tick
        screen_h => 480   -- vertical resolution (e.g., 480)
    )
    port map(
        	clk       => counter_pulse,
            rst       => global_reset,
            fire      => key_A_raw,
            direction => '1',               -- downwards (y increasing)
            tank_x    => tank1x,
            tank_y    => tank1y,
            active    => bullet1_active,
            x_out     => bullet1x,
            y_out     => bullet1y
    );

	--bullet2 instance
	bullet2: bullet
    generic map(
        speed => 10,    -- pixels per tick
        screen_h => 480   -- vertical resolution (e.g., 480)
    )
    port map(
        	clk       => counter_pulse,
            rst       => global_reset,
            fire      => key_K_raw,
            direction => '0',               -- downwards (y increasing)
            tank_x    => tank2x,
            tank_y    => tank2y,
            active    => bullet2_active,
            x_out     => bullet2x,
            y_out     => bullet2y
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

            key_A         => key_A_raw,
            key_S         => key_S_raw,
            key_K         => key_K_raw,
            key_L         => key_L_raw,

            hex0          => ps2_hex0
        );
		ps2_reset <= not global_reset;
		
		-- LEDs reflect raw key states
		kb_leds(3) <= key_A_raw;
		kb_leds(2) <= key_S_raw;
		kb_leds(1) <= key_K_raw;
		kb_leds(0) <= key_L_raw;

	--collisions	
	collision_1_2 : collision
		generic map(
			tank_size_x   => 60,
			tank_size_y   => 40,
			bullet_size_x => 3,
			bullet_size_y => 6
		)
		port map(
			x_bullet        => bullet1x,
			y_bullet        => bullet1y,
			x_tank          => tank2x,
			y_tank          => tank2y,
			collision_signal => hit_1_on_2
		);
	
	collision_2_1 : collision
		generic map(
			tank_size_x   => 60,
			tank_size_y   => 40,
			bullet_size_x => 3,
			bullet_size_y => 6
		)
		port map(
			x_bullet        => bullet2x,
			y_bullet        => bullet2y,
			x_tank          => tank1x,
			y_tank          => tank1y,
			collision_signal => hit_2_on_1
		);

	--led indicators for hits
	led_hit_1_on_2 <= hit_1_on_2;
	led_hit_2_on_1 <= hit_2_on_1;

end architecture structural;