library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity keyboard_test_top is
    port(
        clk_50      : in  std_logic;               -- 50 MHz clock from board
        reset       : in  std_logic;               -- active-high reset
        ps2_clk     : in  std_logic;               -- connect to PS2 clock pin
        ps2_data    : in  std_logic;               -- connect to PS2 data pin
        leds        : out std_logic_vector(3 downto 0)  -- map these 4 pins to DE2 LEDs
    );
end entity;

architecture rtl of keyboard_test_top is

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

    -- unused game control signals (required by keyboard_control)
    signal t1_speed_s : std_logic_vector(1 downto 0);
    signal t1_fire_s  : std_logic;
    signal t2_speed_s : std_logic_vector(1 downto 0);
    signal t2_fire_s  : std_logic;

    -- indicators from keyboard_control
    signal ledA_s, ledS_s, ledK_s, ledL_s : std_logic;

begin

    kb_ctrl : keyboard_control
        port map(
            clk_50        => clk_50,
            reset         => reset,
            keyboard_clk  => ps2_clk,
            keyboard_data => ps2_data,
            tank1_speed   => t1_speed_s,
            tank1_fire    => t1_fire_s,
            tank2_speed   => t2_speed_s,
            tank2_fire    => t2_fire_s,
            led_A         => ledA_s,
            led_S         => ledS_s,
            led_K         => ledK_s,
            led_L         => ledL_s
        );

    -- pack the four key indicator signals to LED outputs
    -- leds(3) = A, leds(2) = S, leds(1) = K, leds(0) = L (choose pin mapping in .qsf)
    leds <= ledA_s & ledS_s & ledK_s & ledL_s;

end architecture rtl;