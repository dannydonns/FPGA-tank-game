library IEEE;
use IEEE.std_logic_1164.all;

package vga_components is
    -- main component
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


end package vga_components;

package body vga_components is

end package body vga_components;