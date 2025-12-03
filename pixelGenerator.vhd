library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pixelGenerator is
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

        --bullet1, bullet2 inputs
        bullet1x, bullet1y : in std_logic_vector(9 downto 0);
        bullet2x, bullet2y : in std_logic_vector(9 downto 0);

        -- vga outputs
        red_out, green_out, blue_out : out std_logic_vector(7 downto 0)
    );
end entity pixelGenerator;
    
architecture behavioral of pixelGenerator is
    constant color_red 	 	 : std_logic_vector(2 downto 0) := "000";
    constant color_green	 : std_logic_vector(2 downto 0) := "001";
    constant color_blue 	 : std_logic_vector(2 downto 0) := "010";
    constant color_yellow 	 : std_logic_vector(2 downto 0) := "011";
    constant color_magenta 	 : std_logic_vector(2 downto 0) := "100";
    constant color_cyan 	 : std_logic_vector(2 downto 0) := "101";
    constant color_black 	 : std_logic_vector(2 downto 0) := "110";
    constant color_white	 : std_logic_vector(2 downto 0) := "111";

    component colorROM is
        port
        (
            address : in std_logic_vector (2 downto 0);
            clock : in std_logic := '1';
            q : out std_logic_vector (23 downto 0)
        );
    end component colorROM;
    
    signal colorAddress : std_logic_vector(2 downto 0);
    signal color : std_logic_vector(23 downto 0);

    signal pixel_row_int, pixel_column_int : natural;
    signal tank_1x, tank_1y : integer;
    signal tank_2x, tank_2y : integer;
    signal bullet_1x, bullet_1y : integer;
    signal bullet_2x, bullet_2y : integer;
    
begin
    --------------------------------------------------------------------------------------------
	
	red_out <= color(23 downto 16);
	green_out <= color(15 downto 8);
	blue_out <= color(7 downto 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));
    tank_1x <= to_integer(unsigned(tank1x));
    tank_1y <= to_integer(unsigned(tank1y));
    tank_2x <= to_integer(unsigned(tank2x));
    tank_2y <= to_integer(unsigned(tank2y));
    bullet_1x <= to_integer(unsigned(bullet1x));
    bullet_1y <= to_integer(unsigned(bullet1y));
    bullet_2x <= to_integer(unsigned(bullet2x));
    bullet_2y <= to_integer(unsigned(bullet2y));

    --------------------------------------------------------------------------------------------	
	
	colors : colorROM
		port map(colorAddress, ROM_clk, color);

    --------------------------------------------------------------------------------------------	
    pixelDraw : process(clk, rst_n) is
	begin
		if (rising_edge(clk)) then
		
			-- if (pixel_row_int < 120 and pixel_column_int < 320) then
			-- 	colorAddress <= color_green;
			-- elsif (pixel_row_int >= 120 and pixel_column_int < 320) then
			-- 	colorAddress <= color_yellow;
			-- elsif (pixel_row_int < 120 and pixel_column_int >= 320) then
			-- 	colorAddress <= color_red;
			-- elsif (pixel_row_int >= 120 and pixel_column_int >= 320) then
			-- 	colorAddress <= color_blue;
			-- else
			-- 	colorAddress <= color_white;
			-- end if;
			-- and (pixel_column_int > tank_1x - tank_size_x) and (pixel_row_int < tank_1y + tank_size_y) and (pixel_row_int > tank_1y - tank_size_y) 
            
            
            if (pixel_column_int < bullet_1x + 3) and (pixel_column_int > bullet_1x) and (pixel_row_int < bullet_1y + 6) and (pixel_row_int > bullet_1y) then
                colorAddress <= color_yellow;
            
            elsif (pixel_column_int < bullet_2x + 3) and (pixel_column_int > bullet_2x) and (pixel_row_int < bullet_2y + 6) and (pixel_row_int > bullet_2y) then
                colorAddress <= color_cyan;

            elsif (pixel_column_int < tank_1x + tank_size_x) and (pixel_column_int > tank_1x) and (pixel_row_int < tank_1y + tank_size_y) and (pixel_row_int > tank_1y) then
                colorAddress <= color_red;
            
            elsif (pixel_column_int < tank_2x + tank_size_x) and (pixel_column_int > tank_2x) and (pixel_row_int < tank_2y + tank_size_y) and (pixel_row_int > tank_2y) then
                colorAddress <= color_green;
            
            else
                colorAddress <= color_white;
            end if;
			
			
		end if;
		
	end process pixelDraw;	

end architecture behavioral;