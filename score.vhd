library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity score is
    port(
        clk, rst  : in std_logic;
        pls_clk   : in std_logic;

        c1, c2    : in std_logic;

        score1, score2 : out std_logic_vector(1 downto 0);
        w1, w2          : out std_logic
    );
end entity score;

architecture behavioral of score is

    --------------------------------------------------------------------
    -- Pulse synchronizer
    --------------------------------------------------------------------
    signal pls_sync0 : std_logic := '0';
    signal pls_sync1 : std_logic := '0';
    signal pls_rise  : std_logic := '0';

    --------------------------------------------------------------------
    -- Internal score registers
    --------------------------------------------------------------------
    signal score1_reg : unsigned(1 downto 0) := (others => '0');
    signal score2_reg : unsigned(1 downto 0) := (others => '0');

    -- collision rising-edge detectors
    signal c1_prev : std_logic := '0';
    signal c2_prev : std_logic := '0';

    signal w1_reg : std_logic := '0';
    signal w2_reg : std_logic := '0';

begin

    --------------------------------------------------------------------
    -- Synchronize pls_clk and detect single-cycle rising edge
    --------------------------------------------------------------------
    sync_proc : process(clk, rst)
    begin
        if rst = '1' then
            pls_sync0 <= '0';
            pls_sync1 <= '0';
            pls_rise  <= '0';
        elsif rising_edge(clk) then
            pls_sync0 <= pls_clk;
            pls_sync1 <= pls_sync0;
            pls_rise  <= pls_sync0 and not pls_sync1;
        end if;
    end process;


    --------------------------------------------------------------------
    -- Scoring logic (runs exactly once for each pls_clk rising edge)
    --------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            score1_reg <= (others => '0');
            score2_reg <= (others => '0');
            c1_prev    <= '0';
            c2_prev    <= '0';
            w1_reg     <= '0';
            w2_reg     <= '0';

        elsif rising_edge(clk) then
            if pls_rise = '1' then

                -- update previous collision values
                c1_prev <= c1;
                c2_prev <= c2;

                ----------------------------------------------------------------
                -- Detect rising edges of collision signals
                ----------------------------------------------------------------
                if (c1 = '1' and c1_prev = '0' and c2 = '0') then
                    if score1_reg < "11" then
                        score1_reg <= score1_reg + 1;
                    end if;
                end if;

                if (c2 = '1' and c2_prev = '0' and c1 = '0') then
                    if score2_reg < "11" then
                        score2_reg <= score2_reg + 1;
                    end if;
                end if;

                ----------------------------------------------------------------
                -- Win conditions (latch high forever)
                ----------------------------------------------------------------
                if score1_reg = "11" then
                    w1_reg <= '1';
                end if;

                if score2_reg = "11" then
                    w2_reg <= '1';
                end if;

            end if; -- pls_rise
        end if; -- rising_edge(clk)
    end process;


    --------------------------------------------------------------------
    -- Outputs
    --------------------------------------------------------------------
    score1 <= std_logic_vector(score1_reg);
    score2 <= std_logic_vector(score2_reg);
    w1     <= w1_reg;
    w2     <= w2_reg;

end architecture behavioral;
