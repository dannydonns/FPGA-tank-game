library IEEE;
use IEEE.std_logic_1164.all;
use work.tank_components.all;

entity vga_top_level is
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
end entity;

architecture structural of vga_top_level is
    --Signals for VGA sync
    signal pixel_row_int 										: std_logic_vector(9 downto 0);
    signal pixel_column_int 									: std_logic_vector(9 downto 0);
    signal video_on_int											: std_logic;
    signal VGA_clk_int											: std_logic;
    signal eof													: std_logic;

    component pixelGenerator is
    generic(
        tank_size_x : integer := 10;
        tank_size_y : integer := 40
    );
    port(
        -- vga inputs
        clk, ROM_clk, rst_n, video_on, eof  : in std_logic;
        pixel_row, pixel_column : in std_logic_vector(9 downto 0);

        -- tank1, tank2 inputs
        tank1x, tank1y : in std_logic_vector(9 downto 0);
        tank2x, tank2y : in std_logic_vector(9 downto 0);

        -- vga outputs
        red_out, green_out, blue_out : out std_logic_vector(7 downto 0)
    );
    end component pixelGenerator;
    -- sync component
    component vga_sync is
    port(
        clock_50Mhz : in std_logic;
        horiz_sync_out, vert_sync_out,
        video_on, pixel_clock, eof : out std_logic;
        pixel_row, pixel_column : out std_logic_vector(9 downto 0)
    );
    end component vga_sync;
begin

--------------------------------------------------------------------------------------------

	videoGen : pixelGenerator
        generic map(10,40)
		port map(clock_50, VGA_clk_int, reset_N, video_on_int, eof, pixel_row_int, pixel_column_int, tank1_x, tank1_y, tank2_x, tank2_y, VGA_RED, VGA_GREEN, VGA_BLUE);

--------------------------------------------------------------------------------------------
--This section should not be modified in your design.  This section handles the VGA timing signals
--and outputs the current row and column.  You will need to redesign the pixelGenerator to choose
--the color value to output based on the current position.

	videoSync : vga_sync
        
		port map(clock_50, horiz_sync, vert_sync, video_on_int, VGA_clk_int, eof, pixel_row_int, pixel_column_int);

	VGA_BLANK <= video_on_int;

	vga_clk <= VGA_clk_int;

--------------------------------------------------------------------------------------------	


end architecture structural;