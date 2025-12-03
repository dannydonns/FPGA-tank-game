-- filepath: c:\Users\zachtey\Documents\quartus_prime_projects\FPGA-tank-game\keyboard_control_tb.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity keyboard_control_tb is
end entity;

architecture tb of keyboard_control_tb is

    -- Clock / reset
    signal clk_50      : std_logic := '0';
    signal reset       : std_logic := '1';

    -- PS/2 wires (driven by TB)
    signal keyboard_clk  : std_logic := '1';
    signal keyboard_data : std_logic := '1';

    -- DUT outputs
    signal tank1_speed  : std_logic_vector(1 downto 0);
    signal tank1_fire   : std_logic;
    signal tank2_speed  : std_logic_vector(1 downto 0);
    signal tank2_fire   : std_logic;
    signal led_A        : std_logic;
    signal led_S        : std_logic;
    signal led_K        : std_logic;
    signal led_L        : std_logic;

    -- PS/2 timing (simulated)
    constant PS2_HALF_PERIOD : time := 15 us; -- half clock period for PS/2 (adjustable)

    -- convenience function
    function xor_reduce(bv : std_logic_vector) return std_logic is
        variable r : std_logic := '0';
    begin
        for i in bv'range loop
            r := r xor bv(i);
        end loop;
        return r;
    end function;

    component keyboard_control
        port(
            clk_50        : in  std_logic;
            reset         : in  std_logic;
            keyboard_clk  : in  std_logic;
            keyboard_data : in  std_logic;
            tank1_speed   : out std_logic_vector(1 downto 0);
            tank1_fire    : out std_logic;
            tank2_speed   : out std_logic_vector(1 downto 0);
            tank2_fire    : out std_logic;
            led_A         : out std_logic;
            led_S         : out std_logic;
            led_K         : out std_logic;
            led_L         : out std_logic
        );
    end component;

begin

    -- DUT instantiation
    dut: keyboard_control
        port map(
            clk_50        => clk_50,
            reset         => reset,
            keyboard_clk  => keyboard_clk,
            keyboard_data => keyboard_data,
            tank1_speed   => tank1_speed,
            tank1_fire    => tank1_fire,
            tank2_speed   => tank2_speed,
            tank2_fire    => tank2_fire,
            led_A         => led_A,
            led_S         => led_S,
            led_K         => led_K,
            led_L         => led_L
        );

    -- 50 MHz clock
    clk_proc : process
    begin
        while now < 200 ms loop
            clk_50 <= '0'; wait for 10 ns;
            clk_50 <= '1'; wait for 10 ns;
        end loop;
        wait;
    end process;

    -- Reset sequence
    reset_proc : process
    begin
        reset <= '1';
        wait for 200 us;
        reset <= '0';
        wait;
    end process;

    -- Stimulus: declare procedure inside process (legal) and use it
    stimulus : process
        -- local procedure to send one PS/2 frame (start, 8 bits LSB-first, odd parity, stop)
        procedure send_ps2_byte(code : in std_logic_vector(7 downto 0)) is
            variable parity   : std_logic;
            variable bit_val  : std_logic;
            variable i        : integer;
        begin
            parity := not xor_reduce(code);

            -- idle
            keyboard_data <= '1';
            keyboard_clk  <= '1';
            wait for PS2_HALF_PERIOD * 2;

            -- start bit (0)
            keyboard_data <= '0';
            wait for PS2_HALF_PERIOD;
            keyboard_clk <= '0';
            wait for PS2_HALF_PERIOD;
            keyboard_clk <= '1';
            wait for PS2_HALF_PERIOD;

            -- 8 data bits LSB-first
            for i in 0 to 7 loop
                bit_val := code(i);
                keyboard_data <= bit_val;
                wait for PS2_HALF_PERIOD;
                keyboard_clk <= '0';
                wait for PS2_HALF_PERIOD;
                keyboard_clk <= '1';
                wait for PS2_HALF_PERIOD;
            end loop;

            -- parity bit
            keyboard_data <= parity;
            wait for PS2_HALF_PERIOD;
            keyboard_clk <= '0';
            wait for PS2_HALF_PERIOD;
            keyboard_clk <= '1';
            wait for PS2_HALF_PERIOD;

            -- stop bit (1)
            keyboard_data <= '1';
            wait for PS2_HALF_PERIOD;
            keyboard_clk <= '0';
            wait for PS2_HALF_PERIOD;
            keyboard_clk <= '1';
            wait for PS2_HALF_PERIOD;

            -- gap
            keyboard_data <= '1';
            keyboard_clk  <= '1';
            wait for 1 ms;
        end procedure;

    begin
        wait until reset = '0';
        wait for 2 ms;

        -- Press A (make 0x1C)
        send_ps2_byte(x"1C");
        wait for 5 ms;
        -- Release A (F0 1C)
        send_ps2_byte(x"F0");
        send_ps2_byte(x"1C");
        wait for 5 ms;

        -- Press S (make 0x1B), release
        send_ps2_byte(x"1B");
        wait for 5 ms;
        send_ps2_byte(x"F0");
        send_ps2_byte(x"1B");
        wait for 5 ms;

        -- Press K (make 0x42), release
        send_ps2_byte(x"42");
        wait for 5 ms;
        send_ps2_byte(x"F0");
        send_ps2_byte(x"42");
        wait for 5 ms;

        -- Press L (make 0x4B), release
        send_ps2_byte(x"4B");
        wait for 5 ms;
        send_ps2_byte(x"F0");
        send_ps2_byte(x"4B");
        wait for 10 ms;

        -- Rapid presses to test edge detection and speed counters
        for i in 1 to 3 loop
            send_ps2_byte(x"1C"); wait for 3 ms;
            send_ps2_byte(x"F0"); send_ps2_byte(x"1C"); wait for 3 ms;
        end loop;

        wait for 20 ms;
        report "Testbench finished" severity failure;
    end process;

end architecture tb;