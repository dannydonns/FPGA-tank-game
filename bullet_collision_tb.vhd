library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bullet_collision_tb is
end entity;

architecture tb of bullet_collision_tb is

    -- DUT ports
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal pls_clk   : std_logic := '0';
    signal fire      : std_logic := '0';
    signal direction : std_logic := '1';  -- '1' = down, '0' = up

    signal shooter_x : unsigned(9 downto 0) := (others => '0');
    signal shooter_y : unsigned(9 downto 0) := (others => '0');

    signal target_x  : unsigned(9 downto 0) := (others => '0');
    signal target_y  : unsigned(9 downto 0) := (others => '0');

    signal bullet_active : std_logic;
    signal bullet_x      : unsigned(9 downto 0);
    signal bullet_y      : unsigned(9 downto 0);

    signal coll      : std_logic;
    signal hit_seen  : std_logic := '0';

begin
    --------------------------------------------------------------------
    -- Clock: 50 MHz (20 ns period)
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    --------------------------------------------------------------------
    -- pls_clk generator: slow pulse from counter
    -- now: 1 pls_clk tick per 10 clk cycles
    --------------------------------------------------------------------
    COUNTER_DUT : entity work.counter
        generic map(
            max_count => 10
        )
        port map(
            clk       => clk,
            rst       => rst,
            pulse_out => pls_clk
        );

    --------------------------------------------------------------------
    -- DUT instantiation: bullet
    --------------------------------------------------------------------
    BULLET_DUT : entity work.bullet
        generic map(
            speed    => 10,
            screen_h => 480
        )
        port map(
            clk       => clk,
            rst       => rst,
            pls_clk   => pls_clk,
            fire      => fire,
            direction => direction,
            tank_x    => shooter_x,
            tank_y    => shooter_y,
            active    => bullet_active,
            x_out     => bullet_x,
            y_out     => bullet_y
        );

    --------------------------------------------------------------------
    -- DUT instantiation: collision
    --------------------------------------------------------------------
    COLLISION_DUT : entity work.collision
        generic map(
            tank_size_x   => 60,
            tank_size_y   => 40,
            bullet_size_x => 3,
            bullet_size_y => 6
        )
        port map(
            x_bullet         => bullet_x,
            y_bullet         => bullet_y,
            x_tank           => target_x,
            y_tank           => target_y,
            collision_signal => coll
        );

    --------------------------------------------------------------------
    -- Simple latch to see if any collision occurred in each scenario
    --------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            hit_seen <= '0';
        elsif rising_edge(clk) then
            if coll = '1' then
                hit_seen <= '1';
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Stimulus: 6 different collision scenarios
    -- Positions + direction are updated on pls_clk edges.
    -- fire is high for 4 clk cycles, starting aligned to pls_clk.
    --------------------------------------------------------------------
    stim_proc : process
        -- Hold 'fire' high for 4 clk cycles
        procedure fire_4cycles is
        begin
            fire <= '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            fire <= '0';
        end procedure;
    begin
        ----------------------------------------------------------------
        -- Global reset
        ----------------------------------------------------------------
        rst       <= '1';
        fire      <= '0';
        direction <= '1';
        shooter_x <= to_unsigned(320, 10);
        shooter_y <= to_unsigned(50, 10);
        target_x  <= to_unsigned(320, 10);
        target_y  <= to_unsigned(150, 10);
        wait for 200 ns;
        rst <= '0';

        -- Let counter start ticking
        wait until rising_edge(pls_clk);
        wait until rising_edge(pls_clk);

        ----------------------------------------------------------------
        -- Scenario 1: shooter below, bullet moves up (hit)
        -- Align shooter/target/direction to pls_clk
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        direction <= '0'; -- up
        shooter_x <= to_unsigned(320, 10);
        shooter_y <= to_unsigned(200, 10);
        target_x  <= to_unsigned(320, 10);
        target_y  <= to_unsigned(120, 10);

        -- On next pls_clk, fire
        wait until rising_edge(pls_clk);
        fire_4cycles;
        wait for 5 us;  -- let bullet travel

        ----------------------------------------------------------------
        -- Reset between scenarios
        ----------------------------------------------------------------
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait until rising_edge(pls_clk);

        ----------------------------------------------------------------
        -- Scenario 2: shooter above, bullet moves down (hit)
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        direction <= '1'; -- down
        shooter_x <= to_unsigned(200, 10);
        shooter_y <= to_unsigned(80, 10);
        target_x  <= to_unsigned(200, 10);
        target_y  <= to_unsigned(180, 10);

        wait until rising_edge(pls_clk);
        fire_4cycles;
        wait for 5 us;

        ----------------------------------------------------------------
        -- Reset between scenarios
        ----------------------------------------------------------------
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait until rising_edge(pls_clk);

        ----------------------------------------------------------------
        -- Scenario 3: slight horizontal offset but still hit
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        direction <= '1'; -- down
        shooter_x <= to_unsigned(250, 10);
        shooter_y <= to_unsigned(60, 10);
        target_x  <= to_unsigned(252, 10); -- small x offset
        target_y  <= to_unsigned(160, 10);

        wait until rising_edge(pls_clk);
        fire_4cycles;
        wait for 5 us;

        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait until rising_edge(pls_clk);

        ----------------------------------------------------------------
        -- Scenario 4: another upward shot, closer vertical gap
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        direction <= '0'; -- up
        shooter_x <= to_unsigned(100, 10);
        shooter_y <= to_unsigned(220, 10);
        target_x  <= to_unsigned(100, 10);
        target_y  <= to_unsigned(180, 10);

        wait until rising_edge(pls_clk);
        fire_4cycles;
        wait for 5 us;

        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait until rising_edge(pls_clk);

        ----------------------------------------------------------------
        -- Scenario 5: downwards with larger gap
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        direction <= '1'; -- down
        shooter_x <= to_unsigned(400, 10);
        shooter_y <= to_unsigned(40, 10);
        target_x  <= to_unsigned(398, 10);
        target_y  <= to_unsigned(200, 10);

        wait until rising_edge(pls_clk);
        fire_4cycles;
        wait for 5 us;

        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait until rising_edge(pls_clk);

        ----------------------------------------------------------------
        -- Scenario 6: final hit, different x and y
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        direction <= '1'; -- down
        shooter_x <= to_unsigned(300, 10);
        shooter_y <= to_unsigned(100, 10);
        target_x  <= to_unsigned(305, 10);
        target_y  <= to_unsigned(260, 10);

        wait until rising_edge(pls_clk);
        fire_4cycles;
        wait for 5 us;

        ----------------------------------------------------------------
        -- Finish simulation
        ----------------------------------------------------------------
        assert false report "End of bullet_collision_tb with 6 collision scenarios" severity failure;
        wait;
    end process;

end architecture tb;
