library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debounce is
    Port (
        clk     : in  STD_LOGIC;
        btn_in  : in  STD_LOGIC;
        btn_out : out STD_LOGIC
    );
end debounce;

architecture Behavioral of debounce is
    signal counter : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
    signal btn_sync : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if btn_in = '1' then
                if counter = X"FFFFF" then
                    btn_sync <= '1';
                else
                    counter <= counter + 1;
                end if;
            else
                counter <= (others => '0');
                btn_sync <= '0';
            end if;
        end if;
    end process;
    btn_out <= btn_sync;
end Behavioral;
