library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity collision is
    generic(
        tank_size_x   : natural := 60;
        tank_size_y   : natural := 40;
        bullet_size_x : natural := 2;
        bullet_size_y : natural := 4
    );
    port(
        -- bullet coords (top-left)
        x_bullet, y_bullet : in unsigned(9 downto 0);

        -- tank coords (top-left)
        x_tank,  y_tank    : in unsigned(9 downto 0);

        -- 1 if rectangles overlap
        collision_signal   : out std_logic
    );
end entity collision;

architecture rtl of collision is
    constant T_SIZE_X_U : unsigned(9 downto 0) := to_unsigned(tank_size_x, 10);
    constant T_SIZE_Y_U : unsigned(9 downto 0) := to_unsigned(tank_size_y, 10);
    constant B_SIZE_X_U : unsigned(9 downto 0) := to_unsigned(bullet_size_x, 10);
    constant B_SIZE_Y_U : unsigned(9 downto 0) := to_unsigned(bullet_size_y, 10);
begin

    comb : process(x_bullet, y_bullet, x_tank, y_tank)
        variable tank_right    : unsigned(9 downto 0);
        variable tank_bottom   : unsigned(9 downto 0);
        variable bullet_right  : unsigned(9 downto 0);
        variable bullet_bottom : unsigned(9 downto 0);
    begin
        -- compute edges
        tank_right    := x_tank   + T_SIZE_X_U;
        tank_bottom   := y_tank   + T_SIZE_Y_U;
        bullet_right  := x_bullet + B_SIZE_X_U;
        bullet_bottom := y_bullet + B_SIZE_Y_U;

        -- AABB overlap test
        if (x_tank < bullet_right) and
           (tank_right > x_bullet) and
           (y_tank < bullet_bottom) and
           (tank_bottom > y_bullet) then
            collision_signal <= '1';
        else
            collision_signal <= '0';
        end if;
    end process comb;

end architecture rtl;

