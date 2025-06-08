-- menu_top.vhd (Poprawiona wersja)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- U?ywaj dla operacji arytmetycznych na UNSIGNED

entity new_menu is
    Port (
        clk     : in  STD_LOGIC;
        btn_l   : in  STD_LOGIC;
        btn_r   : in  STD_LOGIC;
        seg_l   : out STD_LOGIC_VECTOR (6 downto 0);
        seg_r   : out STD_LOGIC_VECTOR (6 downto 0)
    );
end new_menu;

architecture Behavioral of new_menu is
    -- Zmieniono typy na UNSIGNED dla operacji arytmetycznych
    signal cnt_l   : UNSIGNED(3 downto 0) := "0000";
    signal cnt_r   : UNSIGNED(3 downto 0) := "0000";
    signal l_counter : INTEGER := 0;
    signal r_counter : INTEGER := 0;
    signal l_repeat_interval : INTEGER; -- Inicjalizacja w procesie
    signal r_repeat_interval : INTEGER; -- Inicjalizacja w procesie
    signal btn_l_d, btn_r_d : STD_LOGIC;
    signal btn_l_prev, btn_r_prev : STD_LOGIC := '1'; -- Przyciski aktywne nisko, wi?c pocz?tkowo '1' (nieaktywne)

    -- Poprawione sta?e dla zegara systemowego 25.175 MHz:
    constant CLK_FREQ : REAL := 25.175e6; -- Cz?stotliwo?? zegara w Hz
    constant HOLD_THRESHOLD : INTEGER := INTEGER(2.0 * CLK_FREQ);     -- Ok. 2 sekundy (pocz?tkowe opó?nienie przed auto-repeat)
    constant MIN_INTERVAL   : INTEGER := INTEGER(0.125 * CLK_FREQ);   -- Minimalny interwa? powtarzania: 0.125 sekundy
    constant ACCELERATION_STEP : INTEGER := INTEGER(0.025 * CLK_FREQ); -- Krok przyspieszenia: 0.025 sekundy (szybkie powtarzanie)

    component seg7_decoder
        Port (
            bcd : in  STD_LOGIC_VECTOR(3 downto 0);
            seg : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component debounce
        Port (
            clk       : in  STD_LOGIC;
            btn_in    : in  STD_LOGIC;
            btn_out   : out STD_LOGIC;   -- Impuls na zboczu (nie u?ywany w tym przypadku, st?d 'open')
            btn_state : out STD_LOGIC    -- Stabilny stan przycisku
        );
    end component;

begin
    -- Instancjonowanie modu?ów debounce dla lewego i prawego przycisku
    -- btn_state z debounce jest mapowany do btn_l_d/btn_r_d, które b?d? u?ywane w logice menu
    debounce_l: debounce port map(clk => clk, btn_in => btn_l, btn_out => open, btn_state => btn_l_d);
    debounce_r: debounce port map(clk => clk, btn_in => btn_r, btn_out => open, btn_state => btn_r_d);

    process(clk)
    begin
        if rising_edge(clk) then

            -- Inicjalizacja interwa?ów powtarzania przy starcie (tylko raz)
            -- Mo?na te? ustawi? to jako sta?e lub inicjalizowa? w reset logic
            if l_repeat_interval = 0 then -- Prosta flaga inicjalizacji
               l_repeat_interval <= HOLD_THRESHOLD;
               r_repeat_interval <= HOLD_THRESHOLD;
            end if;


            -- Najwy?szy priorytet: oba przyciski wci?ni?te (kopiowanie warto?ci)
            if btn_l_d = '0' and btn_r_d = '0' then
                cnt_r <= cnt_l;
                -- Zresetuj liczniki auto-repeat, aby nie aktywowa?y si? po puszczeniu obu
                l_counter <= 0;
                l_repeat_interval <= HOLD_THRESHOLD;
                r_counter <= 0;
                r_repeat_interval <= HOLD_THRESHOLD;

            -- Lewy przycisk wci?ni?ty (inkrementacja)
            elsif btn_l_d = '0' then
                -- Wykryj zbocze opadaj?ce (pierwsze wci?ni?cie po zwolnieniu)
                if btn_l_prev = '1' then
                    if cnt_l = "1001" then
                        cnt_l <= "0000";
                    else
                        cnt_l <= cnt_l + 1;
                    end if;
                    l_counter <= 1; -- Rozpocznij odliczanie dla auto-repeat
                    l_repeat_interval <= HOLD_THRESHOLD; -- Zresetuj interwa? do pocz?tkowej warto?ci
                -- Przycisk jest trzymany (auto-repeat)
                else -- btn_l_prev = '0', czyli przycisk by? ju? wci?ni?ty w poprzednim cyklu
                    l_counter <= l_counter + 1;
                    if l_counter >= l_repeat_interval then -- U?yj >= dla pewno?ci
                        if cnt_l = "1001" then
                            cnt_l <= "0000";
                        else
                            cnt_l <= cnt_l + 1;
                        end if;

                        -- Przyspieszanie interwa?u powtarzania
                        if l_repeat_interval > MIN_INTERVAL then
                            l_repeat_interval <= l_repeat_interval - ACCELERATION_STEP;
                        end if;
                        l_counter <= 0; -- Zresetuj licznik do kolejnego powtórzenia
                    end if;
                end if;
                -- Upewnij si?, ?e stan auto-repeat prawego przycisku jest zresetowany
                r_counter <= 0;
                r_repeat_interval <= HOLD_THRESHOLD;


            -- Prawy przycisk wci?ni?ty (dekrementacja)
            elsif btn_r_d = '0' then
                -- Wykryj zbocze opadaj?ce (pierwsze wci?ni?cie po zwolnieniu)
                if btn_r_prev = '1' then
                    if cnt_l = "0000" then
                        cnt_l <= "1001";
                    else
                        cnt_l <= cnt_l - 1;
                    end if;
                    r_counter <= 1; -- Rozpocznij odliczanie dla auto-repeat
                    r_repeat_interval <= HOLD_THRESHOLD; -- Zresetuj interwa? do pocz?tkowej warto?ci
                -- Przycisk jest trzymany (auto-repeat)
                else -- btn_r_prev = '0', czyli przycisk by? ju? wci?ni?ty w poprzednim cyklu
                    r_counter <= r_counter + 1;
                    if r_counter >= r_repeat_interval then -- U?yj >= dla pewno?ci
                        if cnt_l = "0000" then
                            cnt_l <= "1001";
                        else
                            cnt_l <= cnt_l - 1;
                        end if;

                        -- Przyspieszanie interwa?u powtarzania
                        if r_repeat_interval > MIN_INTERVAL then
                            r_repeat_interval <= r_repeat_interval - ACCELERATION_STEP;
                        end if;
                        r_counter <= 0; -- Zresetuj licznik do kolejnego powtórzenia
                    end if;
                end if;
                -- Upewnij si?, ?e stan auto-repeat lewego przycisku jest zresetowany
                l_counter <= 0;
                l_repeat_interval <= HOLD_THRESHOLD;

            -- ?aden przycisk nie jest wci?ni?ty (zresetuj liczniki auto-repeat)
            else
                l_counter <= 0;
                l_repeat_interval <= HOLD_THRESHOLD;
                r_counter <= 0;
                r_repeat_interval <= HOLD_THRESHOLD;
            end if;

            -- Zawsze aktualizuj poprzednie stany przycisków na koniec cyklu
            btn_l_prev <= btn_l_d;
            btn_r_prev <= btn_r_d;
        end if;

    end process;

    -- Mapowanie liczników na dekodery 7-segmentowe
    -- Nale?y jawnie skonwertowa? UNSIGNED na STD_LOGIC_VECTOR dla seg7_decoder
    u1: seg7_decoder port map(bcd => STD_LOGIC_VECTOR(cnt_l), seg => seg_l);
    u2: seg7_decoder port map(bcd => STD_LOGIC_VECTOR(cnt_r), seg => seg_r);
end Behavioral;
