library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity full_game_runs is
end entity full_game_runs;

architecture tb of full_game_runs is
    -- clock/reset
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal pls_clk : std_logic := '0';

    -- collision inputs
    signal c1  : std_logic := '0';
    signal c2  : std_logic := '0';

    -- DUT outputs
    signal score1 : std_logic_vector(1 downto 0);
    signal score2 : std_logic_vector(1 downto 0);
    signal w1     : std_logic;
    signal w2     : std_logic;

    constant CLK_PERIOD : time := 10 ns;
begin
    ------------------------------------------------------------------------
    -- DUT instantiation
    ------------------------------------------------------------------------
    DUT : entity work.score
        port map(
            clk     => clk,
            rst     => rst,
            pls_clk => pls_clk,
            c1      => c1,
            c2      => c2,
            score1  => score1,
            score2  => score2,
            w1      => w1,
            w2      => w2
        );

    ------------------------------------------------------------------------
    -- pls_clk generator using counter: 1 pulse per 10 clk cycles
    ------------------------------------------------------------------------
    COUNTER_DUT : entity work.counter
        generic map(
            max_count => 10
        )
        port map(
            clk       => clk,
            rst       => rst,
            pulse_out => pls_clk
        );

    ------------------------------------------------------------------------
    -- Clock generator
    ------------------------------------------------------------------------
    clk_gen : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    ------------------------------------------------------------------------
    -- Stimulus: many different scoring "runs"
    -- Now aligned to pls_clk, with 4-cycle wide c1/c2 pulses.
    ------------------------------------------------------------------------
    stim : process
        -- 4-cycle pulse helper
        procedure pulse_4cycles(signal s : out std_logic) is
        begin
            s <= '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            s <= '0';
        end procedure;

        -- small helper to wait N pls_clk pulses
        procedure wait_pls(n: integer) is
        begin
            for i in 1 to n loop
                wait until rising_edge(pls_clk);
            end loop;
        end procedure;
    begin
        --------------------------------------------------------------------
        -- Global initial reset
        --------------------------------------------------------------------
        rst <= '1';
        c1  <= '0';
        c2  <= '0';
        wait for 3*CLK_PERIOD;   -- initial settle on clk
        rst <= '0';

        -- let pls_clk start ticking
        wait_pls(2);

        -- SCENARIO 1: Player 1 scores 3 times in a row and wins
        -- Hit 1 (P1)
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(1);

        -- Hit 2 (P1)
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(1);

        -- Hit 3 (P1)
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(3);  -- settle

        assert (score1 = "11" and w1 = '1')
            report "Scenario 1: expected player 1 to have score=3 and w1=1"
            severity note;

        assert (score2 = "00" and w2 = '0')
            report "Scenario 1: expected player 2 to have score=0 and w2=0"
            severity note;

        --------------------------------------------------------------------
        -- SCENARIO 2: Extra hits for P1 after win (should not increase)
        --------------------------------------------------------------------
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(1);

        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(2);

        assert (score1 = "11")
            report "Scenario 2: player 1 score should stay saturated at 3"
            severity note;

        --------------------------------------------------------------------
        -- Reset game: everything should clear
        --------------------------------------------------------------------
        rst <= '1';
        wait for 3*CLK_PERIOD;
        rst <= '0';
        wait_pls(2);

        assert (score1 = "00" and score2 = "00" and w1 = '0' and w2 = '0')
            report "After reset 1: scores and win flags should be cleared"
            severity note;

        --------------------------------------------------------------------
        -- SCENARIO 3: Player 2 scores 3 times in a row and wins
        --------------------------------------------------------------------
        -- Hit 1 (P2)
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(1);

        -- Hit 2 (P2)
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(1);

        -- Hit 3 (P2)
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(3);

        assert (score2 = "11" and w2 = '1')
            report "Scenario 3: expected player 2 to have score=3 and w2=1"
            severity note;

        assert (score1 = "00" and w1 = '0')
            report "Scenario 3: expected player 1 still at score=0 and w1=0"
            severity note;

        --------------------------------------------------------------------
        -- Reset again
        --------------------------------------------------------------------
        rst <= '1';
        wait for 2*CLK_PERIOD;
        rst <= '0';
        wait_pls(2);

        assert (score1 = "00" and score2 = "00" and w1 = '0' and w2 = '0')
            report "After reset 2: scores and win flags should be cleared"
            severity note;

        --------------------------------------------------------------------
        -- SCENARIO 4: Alternating hits P1, P2, P1, P2
        --------------------------------------------------------------------
        -- P1 hit
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(1);

        -- P2 hit
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(1);

        -- P1 hit
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(1);

        -- P2 hit
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(2);

        assert (score1 = "10" and score2 = "10")
            report "Scenario 4: alternating hits should give score1=2, score2=2"
            severity note;

        assert (w1 = '0' and w2 = '0')
            report "Scenario 4: no one should have won yet"
            severity note;

        --------------------------------------------------------------------
        -- SCENARIO 5: Simultaneous hits (c1=c2='1') should not score
        --------------------------------------------------------------------
        wait until rising_edge(pls_clk);
        c1 <= '1';
        c2 <= '1';
        -- long enough high to be clearly seen
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        c1 <= '0';
        c2 <= '0';
        wait_pls(2);

        assert (score1 = "10" and score2 = "10")
            report "Scenario 5: simultaneous hits should not change scores"
            severity note;

        --------------------------------------------------------------------
        -- SCENARIO 6: Long pulse on c1 (stays high multiple clocks)
        -- Only the first rising edge should count
        --------------------------------------------------------------------
        wait until rising_edge(pls_clk);
        c1 <= '1';
        -- keep high across several pls_clk pulses
        wait_pls(5);
        c1 <= '0';
        wait_pls(2);

        assert (score1 = "11")  -- from 2 to 3, only once
            report "Scenario 6: long pulse on c1 should increment P1 only once"
            severity note;

        assert (w1 = '1')
            report "Scenario 6: P1 should now be winner"
            severity note;

        --------------------------------------------------------------------
        -- SCENARIO 7: While P1 already winner, P2 tries scoring
        --------------------------------------------------------------------
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(1);

        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(2);

        assert (score2 = "11")
            report "Scenario 7: Player 2 can still reach 3 even if P1 already winner"
            severity note;

        assert (w2 = '1')
            report "Scenario 7: P2 should also show winner flag once score2=3"
            severity note;

        --------------------------------------------------------------------
        -- Reset a third time
        --------------------------------------------------------------------
        rst <= '1';
        wait for 3*CLK_PERIOD;
        rst <= '0';
        wait_pls(2);

        assert (score1 = "00" and score2 = "00" and w1 = '0' and w2 = '0')
            report "After reset 3: everything should be cleared again"
            severity note;

        --------------------------------------------------------------------
        -- SCENARIO 8: Mixed rapid sequence (chaotic pattern)
        --------------------------------------------------------------------
        -- P1 hit
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(1);

        -- P1 hit again quickly
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(2);

        -- P2 double pulse with short gap (two edges)
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(1);
        wait until rising_edge(pls_clk);
        pulse_4cycles(c2);
        wait_pls(2);

        -- One more P1 hit
        wait until rising_edge(pls_clk);
        pulse_4cycles(c1);
        wait_pls(3);

        -- Now check final scores
        assert (score1 = "11")  -- 3 hits total for P1
            report "Scenario 8: expected player 1 to reach score=3 again"
            severity note;

        assert (score2 = "10")  -- 2 hits total for P2
            report "Scenario 8: expected player 2 to reach score=2"
            severity note;

        --------------------------------------------------------------------
        -- End of all scenarios
        --------------------------------------------------------------------
        wait_pls(5);
        assert false report "End of extended score testbench simulation"
            severity failure;
    end process;

end architecture tb;
