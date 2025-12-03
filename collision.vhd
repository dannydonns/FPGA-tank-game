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



-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity collision is
--     generic(
--         tank_size_x : natural;
--         tank_size_y : natural;
--         bullet_size_x : natural;
--         bullet_size_y : natural;
--     );
--     port(
--         -- clock and reset
--         clk, rst : in std_logic;

--         -- bullet coords
--         x_bullet, y_bullet : in unsigned(9 downto 0);

--         -- opposing tank coords
--         x_tank, y_tank : in unsigned(9 downto 0);

--         -- out signal (1 if there is a hit, 0 otherwise)
--         collision_signal : out std_logic
--     );

-- end entity;


-- architecture behavioral of collision is

--     -- collision detection function 
--     function detect_collision(
--         x_t: unsigned(9 downto 0);
--         y_t: unsigned(9 downto 0);
--         t_size_x: unsigned(9 downto 0);
--         t_size_y: unsigned(9 downto 0);
--         x_b: unsigned(9 downto 0);
--         y_b: unsigned(9 downto 0);
--         b_size_x: unsigned(9 downto 0);
--         b_size_y: unsigned(9 downto 0)
--     ) return std_logic is
--         variable col : std_logic := '0';

--         -- precompute edges
--         variable tank_right    : unsigned(9 downto 0);
--         variable tank_bottom   : unsigned(9 downto 0);
--         variable bullet_right  : unsigned(9 downto 0);
--         variable bullet_bottom : unsigned(9 downto 0);
--     begin
--         tank_right    := x_t + t_size_x;
--         tank_bottom   := y_t + t_size_y;
--         bullet_right  := x_b + b_size_x;
--         bullet_bottom := y_b + b_size_y;

--         -- AABB overlap test
--         if (x_t < bullet_right) and
--         (tank_right > x_b) and
--         (y_t < bullet_bottom) and
--         (tank_bottom > y_b) then
--             col := '1';
--         else
--             col := '0';
--         end if;

--         return col;
--     end function;
    
--     -- state variables
--     signal col_curr : std_logic := '0';
--     signal col_nxt : std_logic := '0';

--     -- size signals
--     signal t_size : unsigned(9 downto 0) := to_unsigned(tank_size, 10);
--     signal b_size : unsigned(9 downto 0) := to_unsigned(tank_size, 10);

-- begin

--     clk_proc : process(clk, rst)
--     begin
--         if(rst = '1') then
--             col_curr <= '0';
--         elsif(rising_edge(clk)) then
--             col_curr <= col_nxt;
--             col_out <= col_curr;
--         end if;
--     end process;

--     state_proc : process(col_curr, x_tank, y_tank, x_bullet, y_bullet)
--     begin
--         col_nxt <= detect_collision(x_tank, y_tank, t_size, x_bullet, y_bullet, b_size);
--     end process;
-- end
