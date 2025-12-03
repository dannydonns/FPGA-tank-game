library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bullet is
    generic(
        speed    : integer := 4;    -- pixels per tick
        screen_h : integer := 480   -- vertical resolution (e.g., 480)
    );
    port(
        clk       : in  std_logic;               -- game tick 
        rst       : in  std_logic;               -- active-high reset

        fire      : in  std_logic;               -- fire button 
        direction : in  std_logic;               -- '0' = up, '1' = down

        tank_x    : in  unsigned(9 downto 0);    -- tank position at spawn time
        tank_y    : in  unsigned(9 downto 0);

        active    : out std_logic;               -- 1 if bullet on screen
        x_out     : out unsigned(9 downto 0);
        y_out     : out unsigned(9 downto 0)
    );
end entity bullet;

architecture rtl of bullet is
    -- internal state
    signal b_active : std_logic := '0';
    signal bx, by   : unsigned(9 downto 0) := (others => '0');

    constant spd   : unsigned(9 downto 0) := to_unsigned(speed, 10);
    constant max_y : unsigned(9 downto 0) := to_unsigned(screen_h - 1, 10);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                b_active <= '0';
                bx       <= (others => '0');
                by       <= (others => '0');

            else
                if b_active = '0' then
                    -- no bullet currently on screen
                    -- if fire is held, spawn at current tank position
                    if fire = '1' then
                        bx       <= tank_x;
                        by       <= tank_y;
                        b_active <= '1';
                    end if;

                else
                    -- bullet is flying
                    if direction = '0' then
                        -- DIRECTION = UP (toward y = 0)
                        if by > spd then
                            -- move up
                            by <= by - spd;
                        else
                            -- reached / passed top edge
                            if fire = '1' then
                                -- immediately respawn from tank
                                bx <= tank_x;
                                by <= tank_y;
                                -- b_active stays '1'
                            else
                                -- stop if no longer firing
                                b_active <= '0';
                            end if;
                        end if;

                    else
                        -- DIRECTION = DOWN (toward y = screen_h - 1)
                        if by < (max_y - spd) then
                            -- move down
                            by <= by + spd;
                        else
                            -- reached / passed bottom edge
                            if fire = '1' then
                                -- immediately respawn from tank
                                bx <= tank_x;
                                by <= tank_y;
                                -- b_active stays '1'
                            else
                                -- stop if no longer firing
                                b_active <= '0';
                            end if;
                        end if;

                    end if;

                end if;
            end if;
        end if;
    end process;

    active <= b_active;
    x_out  <= bx;
    y_out  <= by;
end architecture rtl;
