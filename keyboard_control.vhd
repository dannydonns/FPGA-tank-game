library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity keyboard_control is
    port(
        clk_50        : in  std_logic;
        reset         : in  std_logic;

        -- raw PS/2 signals from the board connector
        keyboard_clk  : in  std_logic;
        keyboard_data : in  std_logic;

        -- game controls
        tank1_speed   : out std_logic_vector(1 downto 0);
        tank1_fire    : out std_logic;
        tank2_speed   : out std_logic_vector(1 downto 0);
        tank2_fire    : out std_logic;

        -- LED outputs for key indicators
        led_A         : out std_logic;
        led_S         : out std_logic;
        led_K         : out std_logic;
        led_L         : out std_logic;

        --scan code debug
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0)
    );
end entity keyboard_control;

architecture rtl of keyboard_control is

    -- PS/2 wrapper component (match your ps2.vhd)
    component ps2 is
        port(
            keyboard_clk  : in  std_logic;
            keyboard_data : in  std_logic;
            clock_50MHz   : in  std_logic;
            reset         : in  std_logic;
            scan_code     : out std_logic_vector(7 downto 0);
            scan_readyo   : out std_logic;
            hist3         : out std_logic_vector(7 downto 0);
            hist2         : out std_logic_vector(7 downto 0);
            hist1         : out std_logic_vector(7 downto 0);
            hist0         : out std_logic_vector(7 downto 0)
        );
    end component;

    component leddcd is
	port(
		data_in : in std_logic_vector(3 downto 0);
		segments_out : out std_logic_vector(6 downto 0)
	);
    end component leddcd;

    -- internal signals from ps2
    signal scan_code    : std_logic_vector(7 downto 0) := (others => '0');
    signal scan_ready   : std_logic;
    signal hist0, hist1, hist2, hist3 : std_logic_vector(7 downto 0) := (others => '0');

    -- synchronous edge detect
    signal scan_ready_prev : std_logic := '0';

    -- break code tracking (F0)
    signal break_pending   : std_logic := '0';

    -- internal registers for speed (unsigned for arithmetic)
    signal t1_speed_reg : unsigned(1 downto 0) := (others => '0');
    signal t2_speed_reg : unsigned(1 downto 0) := (others => '0');

    -- fire pulses (one 50 MHz clock cycle pulse)
    signal t1_fire_reg  : std_logic := '0';
    signal t2_fire_reg  : std_logic := '0';

    -- LED indicator registers for keys A,S,K,L
    signal led_A_reg : std_logic := '0';
    signal led_S_reg : std_logic := '0';
    signal led_K_reg : std_logic := '0';
    signal led_L_reg : std_logic := '0';

    -- PS/2 scan codes (make codes)
    constant SC_BREAK : std_logic_vector(7 downto 0) := x"F0";
    constant SC_A     : std_logic_vector(7 downto 0) := x"1C";
    constant SC_S     : std_logic_vector(7 downto 0) := x"1B";
    constant SC_K     : std_logic_vector(7 downto 0) := x"42";
    constant SC_L     : std_logic_vector(7 downto 0) := x"4B";

    --scan code debug outputs
    signal scan_lo : std_logic_vector(3 downto 0);
    signal scan_hi : std_logic_vector(3 downto 0);


begin

    ps2_inst : ps2
        port map(
            keyboard_clk  => keyboard_clk,
            keyboard_data => keyboard_data,
            clock_50MHz   => clk_50,
            reset         => reset,
            scan_code     => scan_code,
            scan_readyo   => scan_ready,
            hist3         => hist3,
            hist2         => hist2,
            hist1         => hist1,
            hist0         => hist0
        );

    -- main control process: synchronous to clk_50
    -- process(clk_50)
    -- begin
    --     if rising_edge(clk_50) then
    --         if reset = '1' then
    --             -- clear state on reset
    --             scan_ready_prev <= '0';
    --             break_pending   <= '0';

    --             t1_speed_reg    <= (others => '0');
    --             t2_speed_reg    <= (others => '0');
    --             t1_fire_reg     <= '0';
    --             t2_fire_reg     <= '0';

    --             led_A_reg <= '0';
    --             led_S_reg <= '0';
    --             led_K_reg <= '0';
    --             led_L_reg <= '0';
    --         else
    --             -- default: no fire this clock
    --             t1_fire_reg <= '0';
    --             t2_fire_reg <= '0';

    --             -- detect rising edge of scan_ready (synchronous)
    --             if (scan_ready = '1' and scan_ready_prev = '0') then
    --                 -- new byte available in scan_code
    --                 if scan_code = SC_BREAK then
    --                     -- next byte will be a key release
    --                     break_pending <= '1';
    --                 else
    --                     if break_pending = '1' then
    --                         -- this byte is the released key -> clear LED and clear break flag
    --                         if scan_code = SC_A then
    --                             led_A_reg <= '0';
    --                         elsif scan_code = SC_S then
    --                             led_S_reg <= '0';
    --                         elsif scan_code = SC_K then
    --                             led_K_reg <= '0';
    --                         elsif scan_code = SC_L then
    --                             led_L_reg <= '0';
    --                         end if;
    --                         break_pending <= '0';
    --                     else
    --                         -- key press (make) -> take action and set LED
    --                         if scan_code = SC_A then
    --                             t1_speed_reg <= t1_speed_reg + to_unsigned(1, t1_speed_reg'length);
    --                             led_A_reg <= '1';
    --                         elsif scan_code = SC_S then
    --                             t1_fire_reg <= '1';
    --                             led_S_reg <= '1';
    --                         elsif scan_code = SC_K then
    --                             t2_speed_reg <= t2_speed_reg + to_unsigned(1, t2_speed_reg'length);
    --                             led_K_reg <= '1';
    --                         elsif scan_code = SC_L then
    --                             t2_fire_reg <= '1';
    --                             led_L_reg <= '1';
    --                         else
    --                             null;
    --                         end if;
    --                     end if;
    --                 end if;
    --             end if;

    --             -- update previous ready flag
    --             scan_ready_prev <= scan_ready;
    --         end if;
    --     end if;
    -- end process;
    process(clk_50)
    begin
        if rising_edge(clk_50) then
            if reset = '1' then
                led_A_reg <= '0';
            else
                if scan_ready = '1' then
                    --if scan_code = SC_A then
                        led_A_reg <= '1';  -- should flip
                    --end if;
                end if;
            end if;
        end if;
    end process;

    scan_hi <= scan_code(7 downto 4);
    scan_lo <= scan_code(3 downto 0);   
    HEX0_inst : leddcd
    port map(
        data_in      => scan_lo,
        segments_out => HEX0    -- 7-segment output
    );

    HEX1_inst : leddcd
        port map(
            data_in      => scan_hi,
            segments_out => HEX1
        );                 

    -- outputs
    tank1_speed <= std_logic_vector(t1_speed_reg);
    tank2_speed <= std_logic_vector(t2_speed_reg);
    tank1_fire  <= t1_fire_reg;
    tank2_fire  <= t2_fire_reg;

    -- LED outputs (invert here if your board LEDs are active-low)
    led_A <= led_A_reg;
    led_S <= led_S_reg;
    led_K <= led_K_reg;
    led_L <= led_L_reg;

end architecture rtl;