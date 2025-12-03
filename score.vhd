library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity score is
    port(
        -- clock, reset
        clk, rst : in std_logic;

        -- collision / hit signals for tank1, tank2
        c1, c2 : in std_logic;

        -- 2-bit scores
        score1, score2 : out std_logic_vector(1 downto 0);

        -- win signals
        w1, w2 : out std_logic
    );  
end entity score;

architecture behavioral of score is

    -- internal score registers as unsigned
    signal score1_reg : unsigned(1 downto 0) := (others => '0');
    signal score2_reg : unsigned(1 downto 0) := (others => '0');

    -- previous values of collision signals to detect rising edges
    signal c1_prev : std_logic := '0';
    signal c2_prev : std_logic := '0';

begin

    --------------------------------------------------------------------
    -- Sequential process: scoring + win logic (all registered)
    --------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            score1_reg <= (others => '0');
            score2_reg <= (others => '0');
            c1_prev    <= '0';
            c2_prev    <= '0';
            w1         <= '0';
            w2         <= '0';

        elsif rising_edge(clk) then
            -- remember previous collision values
            c1_prev <= c1;
            c2_prev <= c2;

            -- default: keep win flags as they are (latch once someone wins)
            -- if you want them to drop on restart, use rst for that
            if score1_reg = "11" then
                w1 <= '1';
            end if;

            if score2_reg = "11" then
                w2 <= '1';
            end if;

            -- detect rising edge on c1: c1 goes 0 -> 1
            if (c1 = '1' and c1_prev = '0' and c2 = '0') then
                if score1_reg < "11" then
                    score1_reg <= score1_reg + 1;
                end if;
            end if;

            -- detect rising edge on c2: c2 goes 0 -> 1
            if (c2 = '1' and c2_prev = '0' and c1 = '0') then
                if score2_reg < "11" then
                    score2_reg <= score2_reg + 1;
                end if;
            end if;
        end if;
    end process;

    -- drive outputs
    score1 <= std_logic_vector(score1_reg);
    score2 <= std_logic_vector(score2_reg);

end architecture behavioral;


-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity score is
--     port(
--         -- clock, reset
--         clk, rst : in std_logic;

--         -- collision / hit signals for tank1, tank2
--         c1, c2 : in std_logic;

--         -- 2-bit scores
--         score1, score2 : out std_logic_vector(1 downto 0);

--         -- win signals
--         w1, w2 : out std_logic
--     );  
-- end entity score;

-- architecture behavioral of score is

--     -- internal score registers as unsigned
--     signal score1_curr : unsigned(1 downto 0);
--     signal score1_nxt  : unsigned(1 downto 0);
--     signal score2_curr : unsigned(1 downto 0);
--     signal score2_nxt  : unsigned(1 downto 0);

-- begin

--     --------------------------------------------------------------------
--     -- Sequential process: registers for scores (with async reset)
--     --------------------------------------------------------------------
--     clk_proc : process(clk, rst)
--     begin
--         if (rst = '1') then
--             score1_curr <= (others => '0');
--             score2_curr <= (others => '0');
--             w1 <= '0';
--             w2 <= '0';
--         elsif rising_edge(clk) then
--             score1_curr <= score1_nxt;
--             score2_curr <= score2_nxt;
--         end if;
--     end process;

--     -- drive outputs from registered scores
--     score1 <= std_logic_vector(score1_curr);
--     score2 <= std_logic_vector(score2_curr);

--     --------------------------------------------------------------------
--     -- Combinational process: next-score logic + win detection
--     --------------------------------------------------------------------
--     state_process : process(score1_curr, score2_curr, c1, c2)
--     begin
--         -- default: hold current scores
--         score1_nxt <= score1_curr;
--         score2_nxt <= score2_curr;

--         -- default: no winner
--         w1 <= '0';
--         w2 <= '0';

--         -- scoring rules (you can tweak these)
--         -- if only c1 is high, player 1 gains a point (up to "11")
--         if (c1 = '1' and c2 = '0') then
--             if score1_curr < "11" then
--                 score1_nxt <= score1_curr + 1;
--             end if;

--         -- if only c2 is high, player 2 gains a point (up to "11")
--         elsif (c2 = '1' and c1 = '0') then
--             if score2_curr < "11" then
--                 score2_nxt <= score2_curr + 1;
--             end if;
--         end if;

--         -- win condition: reaching "11" (3 in decimal)
--         if score1_nxt = "11" then
--             w1 <= '1';
--         end if;

--         if score2_nxt = "11" then
--             w2 <= '1';
--         end if;
--     end process;

-- end architecture behavioral;
