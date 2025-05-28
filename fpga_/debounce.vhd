library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Port (
        clk     : in  STD_LOGIC;
        btn_in  : in  STD_LOGIC;
        btn_out : out STD_LOGIC
    );
end debounce;

architecture Behavioral of debounce is
    -- 20 ms przy clk 25 MHz = 20ms / 40ns = 500000 cykli
    constant DEBOUNCE_LIMIT : unsigned(18 downto 0) := to_unsigned(500000, 19);
    signal counter : unsigned(18 downto 0) := (others => '0');
    signal btn_sync : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if btn_in = '1' then
                if counter < DEBOUNCE_LIMIT then
                    counter <= counter + 1;
                end if;

                if counter = DEBOUNCE_LIMIT then
                    btn_sync <= '1';
                end if;
            else
                counter <= (others => '0');
                btn_sync <= '0';
            end if;
        end if;
    end process;

    btn_out <= btn_sync;
end Behavioral;



