library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity score_tb is
end entity;

architecture sim of score_tb is

    -- DUT ports
    signal clk    : std_logic := '0';
    signal rst    : std_logic := '1';
    signal c1     : std_logic := '0';
    signal c2     : std_logic := '0';
    signal score1 : std_logic_vector(1 downto 0);
    signal score2 : std_logic_vector(1 downto 0);
    signal w1     : std_logic;
    signal w2     : std_logic;

begin
    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    DUT : entity work.score
        port map(
            clk    => clk,
            rst    => rst,
            c1     => c1,
            c2     => c2,
            score1 => score1,
            score2 => score2,
            w1     => w1,
            w2     => w2
        );

    --------------------------------------------------------------------
    -- Clock generator: 10 ns period (100 MHz)
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    --------------------------------------------------------------------
    -- Test sequence, ends simulation automatically
    --------------------------------------------------------------------
    stim_proc : process
    begin
        -- Hold reset for 20ns
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        ----------------------------------------------------------------
        -- Score player 1 three times
        ----------------------------------------------------------------
        wait for 30 ns;
        c1 <= '1'; wait for 10 ns; c1 <= '0';

        wait for 40 ns;
        c1 <= '1'; wait for 10 ns; c1 <= '0';

        wait for 40 ns;
        c1 <= '1'; wait for 10 ns; c1 <= '0';

        ----------------------------------------------------------------
        -- Score player 2 one time
        ----------------------------------------------------------------
        wait for 40 ns;
        c2 <= '1'; wait for 10 ns; c2 <= '0';

        ----------------------------------------------------------------
        -- Give P1 last point to reach "11" (win)
        ----------------------------------------------------------------
        wait for 40 ns;
        c1 <= '1'; wait for 10 ns; c1 <= '0';

        -- Let a few clocks pass to observe w1=1
        wait for 50 ns;

        ----------------------------------------------------------------
        -- END SIMULATION
        ----------------------------------------------------------------
        report "Simulation done." severity note;
        assert false report "End of testbench stop simulation." severity failure;
    end process;

end architecture sim;
