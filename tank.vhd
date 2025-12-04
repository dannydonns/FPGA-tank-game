library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tank is
    generic(
        x_start, y_start : natural;
        tank_size : natural
    );
    port(
        clk, rst  : in std_logic;
        pls_clk   : in std_logic;           -- treated as clock enable
        speed     : in std_logic;

        x_out, y_out : out unsigned(9 downto 0)
    );
end entity tank;





architecture behavioral of tank is
    -- x, y signals
    -- Synchronizer for pls_clk
    signal pls_sync_0 : std_logic := '0';
    signal pls_sync_1 : std_logic := '0';
    signal pls_rise   : std_logic := '0';

    -- x, y signals
    signal x_curr : unsigned(9 downto 0) := to_unsigned(x_start, 10);
    signal x_nxt  : unsigned(9 downto 0) := to_unsigned(x_start, 10);
    signal y_t    : unsigned(9 downto 0) := to_unsigned(y_start, 10);

    -- state declaration
    signal dir_curr : std_logic := '0';
    signal dir_nxt  : std_logic := '0';
    signal key_curr : std_logic := '0';
    signal key_nxt  : std_logic := '0';
    signal spd_curr : std_logic_vector(1 downto 0) := "00";
    signal spd_nxt  : std_logic_vector(1 downto 0) := "00";

    function advance_tank(dir: std_logic; x : unsigned; spd: std_logic_vector(1 downto 0))
        return unsigned is
        variable x_adv : unsigned(9 downto 0);
    begin
        case spd is
            when "01" =>
                if dir='0' then x_adv := x - 2; else x_adv := x + 2; end if;
            when "10" =>
                if dir='0' then x_adv := x - 3; else x_adv := x + 3; end if;
            when others =>
                if dir='0' then x_adv := x - 1; else x_adv := x + 1; end if;
        end case;

        return x_adv;
    end function;

begin
    y_out <= y_t;

	sync_process : process(clk, rst)
	begin
		if rst = '1' then
			pls_sync_0 <= '0';
			pls_sync_1 <= '0';
			pls_rise   <= '0';

		elsif rising_edge(clk) then
			pls_sync_0 <= pls_clk;          -- sync stage 1
			pls_sync_1 <= pls_sync_0;       -- sync stage 2 (safe signal)

			-- rising edge detector
			pls_rise <= pls_sync_0 and not pls_sync_1;
		end if;
	end process;

	clk_process : process(clk, rst)
	begin
		if rst = '1' then
			dir_curr <= '0';
			spd_curr <= "00";
			x_curr   <= to_unsigned(x_start, 10);
			key_curr <= '0';

		elsif rising_edge(clk) then
			if pls_rise = '1' then     -- SINGLE UPDATE PER PULSE
				dir_curr <= dir_nxt;
				x_curr   <= x_nxt;
				spd_curr <= spd_nxt;
				key_curr <= key_nxt;
			end if;
		end if;
	end process;


    direction_process : process(x_curr, dir_curr, speed, spd_curr, key_curr)
    begin
        -- boundary direction logic
        case dir_curr is
            when '0' =>
                if x_curr < to_unsigned(15, 10) then
                    dir_nxt <= '1';
                else
                    dir_nxt <= '0';
                end if;

            when '1' =>
                if x_curr > to_unsigned(640 - tank_size, 10) then
                    dir_nxt <= '0';
                else
                    dir_nxt <= '1';
                end if;

            when others =>
                dir_nxt <= '0';
        end case;

        -- speed logic
        if (speed = '1' and key_curr = '0') then
            case spd_curr is
                when "00" => spd_nxt <= "01";
                when "01" => spd_nxt <= "10";
                when others => spd_nxt <= "00";
            end case;
        else
            spd_nxt <= spd_curr;
        end if;

        key_nxt <= speed;

        -- movement
        x_nxt <= advance_tank(dir_curr, x_curr, spd_curr);
    end process;

    x_out <= x_curr;

end architecture behavioral;
