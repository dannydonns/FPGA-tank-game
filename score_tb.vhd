library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity score_tb is
end entity;

architecture sim of score_tb is

    -- DUT ports
    signal pls_clk    : std_logic := '0';
    signal clk_100    : std_logic := '0';
    signal rst        : std_logic := '1';
    signal c1         : std_logic := '0';
    signal c2         : std_logic := '0';
    signal score1     : std_logic_vector(1 downto 0);
    signal score2     : std_logic_vector(1 downto 0);
    signal w1         : std_logic;
    signal w2         : std_logic;

begin
    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    SCORE_DUT : entity work.score
        port map(
            clk     => clk_100,
            rst     => rst,
            pls_clk => pls_clk,
            c1      => c1,
            c2      => c2,
            score1  => score1,
            score2  => score2,
            w1      => w1,
            w2      => w2
        );

    -- pls_clk pulses every ~100 clk_100 cycles
    COUNTER_DUT: entity work.counter
        generic map(
            max_count => 100
        )
        port map(
            clk       => clk_100,
            rst       => rst,
            pulse_out => pls_clk
        );

    --------------------------------------------------------------------
    -- 100 MHz clock generator
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk_100 <= '0';
        wait for 5 ns;
        clk_100 <= '1';
        wait for 5 ns;
    end process;

    --------------------------------------------------------------------
    -- Test sequence using *4-cycle-wide* c1/c2 pulses
    --------------------------------------------------------------------
    stim_proc : process
        -- utility to hold a signal high for 4 clk_100 cycles
        procedure pulse_4cycles(signal s : out std_logic) is
        begin
            s <= '1';
            wait until rising_edge(clk_100);
            wait until rising_edge(clk_100);
            wait until rising_edge(clk_100);
            wait until rising_edge(clk_100);
            s <= '0';
        end procedure;
    begin
        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- allow pls_clk to start ticking
        wait until rising_edge(pls_clk);

        ----------------------------------------------------------------
        -- Score player 1 three times
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);

        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);

        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);

        ----------------------------------------------------------------
        -- Score player 2 once
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);

        ----------------------------------------------------------------
        -- Final P1 point (expected to trigger win)
        ----------------------------------------------------------------
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);

        -- observe win output
        wait until rising_edge(pls_clk);

        ----------------------------------------------------------------
        -- END SIMULATION
        ----------------------------------------------------------------
        report "Simulation done." severity note;
        assert false report "End of testbench stop simulation." severity failure;
    end process;

end architecture sim;
