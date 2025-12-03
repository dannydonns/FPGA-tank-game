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
--     signal 

-- begin

--     clk_proc : process(clk, rst)
--     begin

--     end process;
-- end 