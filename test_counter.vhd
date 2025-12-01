library IEEE;
use IEEE.std_logic_1164.all;
use work.tank_components.all;

entity counter_tb is
    generic(
        mx_cnt : integer := 50000000
    );
    port(
        F_clk : out std_logic; -- input clock (50 MHz)
        F_out : out std_logic -- output pulse
    );
end entity counter_tb;


architecture test of counter_tb is
    signal clk_sim : std_logic := '0';
    signal rst_sim : std_logic := '0';
    -- component declaration
    component counter
        generic(
            max_count : integer
        );
        port(
            clk : in std_logic;
            rst : in std_logic;
            pulse_out : out std_logic
        );
    end component counter;
begin
    dut : counter
        generic map(max_count => mx_cnt)
        port map (
            -- inputs
            clk => clk_sim,
            rst => rst_sim,

            -- outputs
            pulse_out => F_out
        );
    F_clk <= clk_sim;

    process is
    begin
        clk_sim <= '0';
        clk_loop : for k in 0 to 10 loop
            wait for 10 ns;
            clk_sim <= '1';
            wait for 10 ns;
            clk_sim <= '0';
        end loop clk_loop;
        wait;
    end process;
end architecture test;