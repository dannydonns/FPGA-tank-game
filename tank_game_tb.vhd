library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tank_game_tb is
end entity;

architecture tb of tank_game_tb is

    -- DUT ports
    signal clk_50        : std_logic := '0';
    signal global_reset  : std_logic := '0';

    signal vga_red       : std_logic_vector(7 downto 0);
    signal vga_green     : std_logic_vector(7 downto 0);
    signal vga_blue      : std_logic_vector(7 downto 0);
    signal horiz_sync    : std_logic;
    signal vert_sync     : std_logic;
    signal vga_blank     : std_logic;
    signal vga_clk       : std_logic;

    signal ps2_clk       : std_logic := '1';
    signal ps2_data      : std_logic := '1';
    signal kb_leds       : std_logic_vector(3 downto 0);

    signal lcd_rs_out    : std_logic;
    signal lcd_e_out     : std_logic;
    signal lcd_on_out    : std_logic;
    signal reset_led_out : std_logic;
    signal sec_led_out   : std_logic;
    signal lcd_rw_out    : std_logic;
    signal data_bus_out  : std_logic_vector(7 downto 0);

    signal led_hit_1_on_2 : std_logic;
    signal led_hit_2_on_1 : std_logic;
    signal one_wins       : std_logic;
    signal two_wins       : std_logic;

begin

    ------------------------------------------------------------------------
    -- DUT INSTANTIATION
    ------------------------------------------------------------------------
    DUT : entity work.tank_game
        port map(
            clk_50        => clk_50,
            global_reset  => global_reset,

            vga_red       => vga_red,
            vga_green     => vga_green,
            vga_blue      => vga_blue,
            horiz_sync    => horiz_sync,
            vert_sync     => vert_sync,
            vga_blank     => vga_blank,
            vga_clk       => vga_clk,

            ps2_clk       => ps2_clk,
            ps2_data      => ps2_data,
            kb_leds       => kb_leds,

            lcd_rs_out    => lcd_rs_out,
            lcd_e_out     => lcd_e_out,
            lcd_on_out    => lcd_on_out,
            reset_led_out => reset_led_out,
            sec_led_out   => sec_led_out,
            lcd_rw_out    => lcd_rw_out,
            data_bus_out  => data_bus_out,

            led_hit_1_on_2 => led_hit_1_on_2,
            led_hit_2_on_1 => led_hit_2_on_1,
            one_wins       => one_wins,
            two_wins       => two_wins
        );

    ------------------------------------------------------------------------
    -- 50 MHz CLOCK (20 ns period)
    ------------------------------------------------------------------------
    clk_proc : process
    begin
        clk_50 <= '0';
        wait for 10 ns;
        clk_50 <= '1';
        wait for 10 ns;
    end process;

    ------------------------------------------------------------------------
    -- GLOBAL RESET SEQUENCE
    ------------------------------------------------------------------------
    rst_proc : process
    begin
        global_reset <= '1';
        wait for 200 ns;              -- hold reset low for a bit
        global_reset <= '0';          -- release reset
        wait;
    end process;

    ------------------------------------------------------------------------
    -- "RANDOM" PS/2 ACTIVITY (doesn't model real PS/2 protocol,
    -- but it exercises the ps2 module with changing inputs)
    ------------------------------------------------------------------------
    ps2_stim : process
        variable lfsr : unsigned(7 downto 0) := x"5A";
    begin
        wait until global_reset = '1';
        wait for 1 us;

        -- run for a few milliseconds
        while now < 5 ms loop
            -- simple 8-bit LFSR
            lfsr := lfsr(6 downto 0) & (lfsr(7) xor lfsr(5));
            ps2_clk  <= std_logic(lfsr(0));
            ps2_data <= std_logic(lfsr(1));
            wait for 50 us;
        end loop;

        wait;
    end process;

    ------------------------------------------------------------------------
    -- END SIM AFTER SOME TIME
    ------------------------------------------------------------------------
    stop_sim : process
    begin
        wait for 20 ms;
        assert false report "tank_game_tb: simulation finished" severity failure;
    end process;

end architecture;

