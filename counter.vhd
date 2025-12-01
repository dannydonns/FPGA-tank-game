library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;


entity counter is
	generic(
		max_count : natural
	);
	port(
		clk : in std_logic := '0';
		rst : in std_logic := '0';
		pulse_out : out std_logic := '0'
	);
end entity counter;

architecture arch of counter is
	signal cnt : std_logic_vector(31 downto 0) := (others => '0');
	signal pulse : std_logic := '0';
begin
	proc1 : process(clk, rst)
	begin
		if (rst = '1') then
			cnt <= (others => '0');
			pulse <= '0';
		elsif (rising_edge(clk)) then
			cnt <= (cnt + 1);
			if(cnt > std_logic_vector(to_unsigned(max_count, 32))) then
				cnt <= (others => '0');
				pulse <= not pulse;
			end if;
		end if;	
		pulse_out <= pulse;
	end process proc1;
end architecture arch;