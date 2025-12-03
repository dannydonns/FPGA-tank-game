LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2 is
    port(
        keyboard_clk, keyboard_data, clock_50MHz,
        reset : in std_logic;
        scan_code    : out std_logic_vector(7 downto 0);
        scan_readyo  : out std_logic;
        hist3        : out std_logic_vector(7 downto 0);
        hist2        : out std_logic_vector(7 downto 0);
        hist1        : out std_logic_vector(7 downto 0);
        hist0        : out std_logic_vector(7 downto 0);

        -- NEW: key state outputs (1 = currently pressed)
        key_A        : out std_logic;
        key_S        : out std_logic;
        key_K        : out std_logic;
        key_L        : out std_logic;

        -- single 7-seg HEX display (keep pin planning simple)
        hex0         : out std_logic_vector(6 downto 0)
    );
end entity ps2;

architecture structural of ps2 is

    component keyboard IS
        PORT(
            keyboard_clk, keyboard_data, clock_50MHz,
            reset, read  : IN  STD_LOGIC;
            scan_code    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            scan_ready   : OUT STD_LOGIC
        );
    end component keyboard;

    component oneshot is
        port(
            pulse_out  : out std_logic;
            trigger_in : in  std_logic;
            clk        : in  std_logic
        );
    end component oneshot;

    component leddcd is
        port(
            data_in      : in  std_logic_vector(3 downto 0);
            segments_out : out std_logic_vector(6 downto 0)
        );
    end component leddcd;

    signal scan2      : std_logic;
    signal scan_code2 : std_logic_vector(7 downto 0);
    signal history3   : std_logic_vector(7 downto 0);
    signal history2   : std_logic_vector(7 downto 0);
    signal history1   : std_logic_vector(7 downto 0);
    signal history0   : std_logic_vector(7 downto 0);
    signal read       : std_logic;
    signal nib0       : std_logic_vector(3 downto 0);
    signal last_make  : std_logic_vector(7 downto 0);

    -- NEW: internal key state registers
    signal key_A_reg  : std_logic := '0';
    signal key_S_reg  : std_logic := '0';
    signal key_K_reg  : std_logic := '0';
    signal key_L_reg  : std_logic := '0';

    -- NEW: remember if previous byte was the break prefix F0
    signal prev_was_break : std_logic := '0';

    -- NEW: scan code constants
    constant SC_BREAK : std_logic_vector(7 downto 0) := x"F0";
    constant SC_A     : std_logic_vector(7 downto 0) := x"1C";
    constant SC_S     : std_logic_vector(7 downto 0) := x"1B";
    constant SC_K     : std_logic_vector(7 downto 0) := x"42";
    constant SC_L     : std_logic_vector(7 downto 0) := x"4B";

begin

    u1: keyboard
        port map(
            keyboard_clk  => keyboard_clk,
            keyboard_data => keyboard_data,
            clock_50MHz   => clock_50MHz,
            reset         => reset,
            read          => read,
            scan_code     => scan_code2,
            scan_ready    => scan2
        );

    pulser: oneshot
        port map(
            pulse_out  => read,
            trigger_in => scan2,
            clk        => clock_50MHz
        );

    scan_readyo <= scan2;
    scan_code   <= scan_code2;

    -- expose history outputs
    hist0 <= history0;
    hist1 <= history1;
    hist2 <= history2;
    hist3 <= history3;

    -- HEX0 shows low nibble of last make code
    nib0 <= last_make(3 downto 0);

    u_led0: leddcd
        port map(
            data_in      => nib0,
            segments_out => hex0
        );

    -- history + key-state update on each scan2 pulse
    a1 : process(scan2)
    begin
        if rising_edge(scan2) then
            -- shift history
            history3 <= history2;
            history2 <= history1;
            history1 <= history0;
            history0 <= scan_code2;

            -- break / make decoding:
            if scan_code2 = SC_BREAK then
                -- next byte will be a break for some key
                prev_was_break <= '1';
            else
                if prev_was_break = '1' then
                    -- this byte is the key that was released (break)
                    if scan_code2 = SC_A then
                        key_A_reg <= '0';
                    elsif scan_code2 = SC_S then
                        key_S_reg <= '0';
                    elsif scan_code2 = SC_K then
                        key_K_reg <= '0';
                    elsif scan_code2 = SC_L then
                        key_L_reg <= '0';
                    end if;
                    prev_was_break <= '0';
                else
                    -- this byte is a make (key press)
                    if scan_code2 = SC_A then
                        key_A_reg <= '1';
                        last_make <= scan_code2;
                    elsif scan_code2 = SC_S then
                        key_S_reg <= '1';
                        last_make <= scan_code2;
                    elsif scan_code2 = SC_K then
                        key_K_reg <= '1';
                        last_make <= scan_code2;
                    elsif scan_code2 = SC_L then
                        key_L_reg <= '1';
                        last_make <= scan_code2;
                    else
                        -- other keys: update last_make but no key_* change
                        last_make <= scan_code2;
                    end if;
                end if;
            end if;
        end if;
    end process a1;

    -- drive outputs
    key_A <= key_A_reg;
    key_S <= key_S_reg;
    key_K <= key_K_reg;
    key_L <= key_L_reg;

end architecture structural;


-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.STD_LOGIC_ARITH.ALL;
-- USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- entity ps2 is
-- 	port( 	keyboard_clk, keyboard_data, clock_50MHz ,
-- 			reset : in std_logic;--, read : in std_logic;
-- 			scan_code : out std_logic_vector( 7 downto 0 );
-- 			scan_readyo : out std_logic;
-- 			hist3 : out std_logic_vector(7 downto 0);
-- 			hist2 : out std_logic_vector(7 downto 0);
-- 			hist1 : out std_logic_vector(7 downto 0);
-- 			hist0 : out std_logic_vector(7 downto 0)
-- 		);
-- end entity ps2;


-- architecture structural of ps2 is

-- component keyboard IS
-- 	PORT( 	keyboard_clk, keyboard_data, clock_50MHz ,
-- 			reset, read : IN STD_LOGIC;
-- 			scan_code : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
-- 			scan_ready : OUT STD_LOGIC);
-- end component keyboard;

-- component oneshot is
-- port(
-- 	pulse_out : out std_logic;
-- 	trigger_in : in std_logic; 
-- 	clk: in std_logic );
-- end component oneshot;

-- signal scan2 : std_logic;
-- signal scan_code2 : std_logic_vector( 7 downto 0 );
-- signal history3 : std_logic_vector(7 downto 0);
-- signal history2 : std_logic_vector(7 downto 0);
-- signal history1 : std_logic_vector(7 downto 0);
-- signal history0 : std_logic_vector(7 downto 0);
-- signal read : std_logic;

-- begin

-- u1: keyboard port map(	
-- 				keyboard_clk => keyboard_clk,
-- 				keyboard_data => keyboard_data,
-- 				clock_50MHz => clock_50MHz,
-- 				reset => reset,
-- 				read => read,
-- 				scan_code => scan_code2,
-- 				scan_ready => scan2
-- 			);

-- pulser: oneshot port map(
--    pulse_out => read,
--    trigger_in => scan2,
--    clk => clock_50MHz
-- 			);

-- scan_readyo <= scan2;
-- scan_code <= scan_code2;

-- hist0<=history0;
-- hist1<=history1;
-- hist2<=history2;
-- hist3<=history3;

-- a1 : process(scan2)
-- begin
-- 	if(rising_edge(scan2)) then
-- 	history3 <= history2;
-- 	history2 <= history1;
-- 	history1 <= history0;
-- 	history0 <= scan_code2;
-- 	end if;
-- end process a1;


-- end architecture structural;