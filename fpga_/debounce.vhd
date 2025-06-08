library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Port (
        clk       : in  STD_LOGIC;
        btn_in    : in  STD_LOGIC;
        btn_out   : out STD_LOGIC;
        btn_state : out STD_LOGIC  -- NOWY SYGNA£
    );
end debounce;

architecture Behavioral of debounce is
    constant DEBOUNCE_LIMIT : unsigned(18 downto 0) := to_unsigned(500000, 19); -- ~20 ms przy 25 MHz
    signal counter     : unsigned(18 downto 0) := (others => '0');
    signal btn_sync_0  : STD_LOGIC := '0';
    signal btn_sync_1  : STD_LOGIC := '0';
    signal btn_deb     : STD_LOGIC := '0';
    signal btn_deb_reg : STD_LOGIC := '0';
begin

    -- Synchronizacja wejœcia
    process(clk)
    begin
        if rising_edge(clk) then
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end if;
    end process;

    -- Logika wyg³adzania (debounce)
    process(clk)
    begin
        if rising_edge(clk) then
            if btn_sync_1 = btn_deb then
                counter <= (others => '0');
            else
                counter <= counter + 1;
                if counter = DEBOUNCE_LIMIT then
                    btn_deb <= btn_sync_1;
                    counter <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- Wygeneruj impuls
    process(clk)
    begin
        if rising_edge(clk) then
            if btn_deb = '1' and btn_deb_reg = '0' then
                btn_out <= '1';
            else
                btn_out <= '0';
            end if;
            btn_deb_reg <= btn_deb;
        end if;
    end process;

    -- Wyjœcie stanu
    btn_state <= btn_deb;

end Behavioral;
