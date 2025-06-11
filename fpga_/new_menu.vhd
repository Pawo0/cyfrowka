library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
    signal cnt_l   : UNSIGNED(3 downto 0) := "0000";
    signal cnt_r   : UNSIGNED(3 downto 0) := "0000";

    -- Sygna�y po debouncingu
    signal btn_l_debounced, btn_r_debounced : STD_LOGIC;
    -- Poprzednie stany po debouncingu do wykrywania zboczy
    signal btn_l_prev_debounced, btn_r_prev_debounced : STD_LOGIC := '1';

    -- Auto-repeat
    signal l_auto_repeat_counter : INTEGER := 0;
    signal r_auto_repeat_counter : INTEGER := 0;
    signal l_current_repeat_interval : INTEGER;
    signal r_current_repeat_interval : INTEGER;

    -- Logika "podw�jnego klikni�cia" lub synchronizacji dw�ch przycisk�w
    signal sync_timer : INTEGER := 0;
    -- Sygnalizuje, �e jeden przycisk jest wci�ni�ty i czekamy na drugi
    signal waiting_for_second_button : BOOLEAN := FALSE;
    -- Zapisuje, kt�ry przycisk by� pierwszy wci�ni�ty
    signal first_button_pressed : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- "01" dla L, "10" dla R, "00" dla brak

    -- Sta�e czasowe (dostosuj do cz�stotliwo�ci zegara FPGA)
    constant CLK_FREQ_HZ       : REAL := 25.175e6; -- Przyk�adowa cz�stotliwo�� 25.175 MHz

    -- Auto-repeat timings
    constant INITIAL_REPEAT_DELAY_CYCLES : INTEGER := INTEGER(0.5 * CLK_FREQ_HZ); -- 0.5 sekundy op�nienia przed pierwszym auto-repeat
    constant FAST_REPEAT_INTERVAL_CYCLES : INTEGER := INTEGER(0.125 * CLK_FREQ_HZ); -- 0.125 sekundy interwa� szybki
    constant ACCELERATION_STEP_CYCLES    : INTEGER := INTEGER(0.025 * CLK_FREQ_HZ); -- Przyspieszenie co 0.025 sekundy

    -- Two-button sync timing
    constant TWO_BUTTON_SYNC_TIMEOUT_CYCLES : INTEGER := INTEGER(0.05 * CLK_FREQ_HZ); -- 50 ms na wci�ni�cie drugiego przycisku

    -- Komponenty zewn�trzne (zak�adamy, �e s� zdefiniowane w osobnych plikach)
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
            btn_out   : out STD_LOGIC; -- Zwykle jest to sygna� pulsuj�cy po wci�ni�ciu/zwolnieniu
            btn_state : out STD_LOGIC  -- Stabilny stan przycisku (0 wci�ni�ty, 1 zwolniony)
        );
    end component;

begin
    -- Instancjonowanie modu��w debounce
    debounce_l_inst: debounce port map(
        clk       => clk,
        btn_in    => btn_l,
        btn_out   => open,
        btn_state => btn_l_debounced
    );

    debounce_r_inst: debounce port map(
        clk       => clk,
        btn_in    => btn_r,
        btn_out   => open,
        btn_state => btn_r_debounced
    );

    process(clk)
    begin
        if rising_edge(clk) then

            -- Inicjalizacja interwa��w auto-repeat (tylko raz na pocz�tku)
            if l_current_repeat_interval = 0 then
               l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
               r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
            end if;

            -- Logika timera synchronizacji dw�ch przycisk�w
            if sync_timer > 0 then
                sync_timer <= sync_timer - 1;
            else
                waiting_for_second_button <= FALSE; -- Czas min��, nie czekamy ju� na drugi przycisk
                first_button_pressed <= "00"; -- Resetuj informacj� o pierwszym wci�ni�tym przycisku
            end if;

            -- --- Priorytet 1: Oba przyciski wci�ni�te ---
            if btn_l_debounced = '0' and btn_r_debounced = '0' then
                cnt_r <= cnt_l; -- Kopiowanie warto�ci (to jest akcja dla obu przycisk�w)

                -- Resetuj wszystkie liczniki i flagi, aby po puszczeniu nie by�o niechcianych akcji
                l_auto_repeat_counter <= 0;
                r_auto_repeat_counter <= 0;
                l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                sync_timer <= 0;
                waiting_for_second_button <= FALSE;
                first_button_pressed <= "00";

            -- --- Priorytet 2: Lewy przycisk jest wci�ni�ty, prawy zwolniony ---
            elsif btn_l_debounced = '0' and btn_r_debounced = '1' then
                -- Wykrycie zbocza opadaj�cego (pierwsze naci�ni�cie lewego przycisku)
                if btn_l_prev_debounced = '1' then
                    -- Aktywuj timer synchronizacji, je�li jeszcze nie jest aktywny
                    if not waiting_for_second_button then
                        sync_timer <= TWO_BUTTON_SYNC_TIMEOUT_CYCLES;
                        waiting_for_second_button <= TRUE;
                        first_button_pressed <= "01"; -- Zapami�taj, �e L by� pierwszy
                    end if;
                    -- Poczekaj na wyga�ni�cie timera lub wci�ni�cie drugiego.
                    l_auto_repeat_counter <= 1; -- Ustaw na 1, aby po wyga�ni�ciu timera by�o gotowe do auto-repeat
                    l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES; -- Reset interwa�u
                end if;

                -- Je�li czekali�my na drugi przycisk (prawy), i ten czas up�yn��
                if waiting_for_second_button = TRUE and sync_timer = 0 and first_button_pressed = "01" then
                    -- Tylko wtedy, gdy to by� faktycznie pierwszy przycisk i okno synchronizacji wygas�o
                    if cnt_l = "1001" then
                        cnt_l <= "0000";
                    else
                        cnt_l <= cnt_l + 1;
                    end if;
                    waiting_for_second_button <= FALSE; -- Operacja wykonana, resetuj
                    first_button_pressed <= "00";
                end if;

                -- Logika auto-repeat (tylko je�li nie czekamy na drugi przycisk lub okno wygas�o)
                if not waiting_for_second_button and btn_l_prev_debounced = '0' then -- Przycisk jest trzymany
                    l_auto_repeat_counter <= l_auto_repeat_counter + 1;
                    if l_auto_repeat_counter >= l_current_repeat_interval then
                        if cnt_l = "1001" then
                            cnt_l <= "0000";
                        else
                            cnt_l <= cnt_l + 1;
                        end if;

                        if l_current_repeat_interval > FAST_REPEAT_INTERVAL_CYCLES then
                            l_current_repeat_interval <= l_current_repeat_interval - ACCELERATION_STEP_CYCLES;
                        end if;
                        l_auto_repeat_counter <= 0;
                    end if;
                end if;

                -- Resetuj stan dla prawego przycisku
                r_auto_repeat_counter <= 0;
                r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;

            -- --- Priorytet 3: Prawy przycisk jest wci�ni�ty, lewy zwolniony ---
            elsif btn_r_debounced = '0' and btn_l_debounced = '1' then
                -- Wykrycie zbocza opadaj�cego (pierwsze naci�ni�cie prawego przycisku)
                if btn_r_prev_debounced = '1' then
                    if not waiting_for_second_button then
                        sync_timer <= TWO_BUTTON_SYNC_TIMEOUT_CYCLES;
                        waiting_for_second_button <= TRUE;
                        first_button_pressed <= "10"; -- Zapami�taj, �e R by� pierwszy
                    end if;
                    r_auto_repeat_counter <= 1;
                    r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                end if;

                -- Je�li czekali�my na drugi przycisk (lewy), i ten czas up�yn��
                if waiting_for_second_button = TRUE and sync_timer = 0 and first_button_pressed = "10" then
                    if cnt_l = "0000" then
                        cnt_l <= "1001";
                    else
                        cnt_l <= cnt_l - 1;
                    end if;
                    waiting_for_second_button <= FALSE;
                    first_button_pressed <= "00";
                end if;

                -- Logika auto-repeat (tylko je�li nie czekamy na drugi przycisk lub okno wygas�o)
                if not waiting_for_second_button and btn_r_prev_debounced = '0' then -- Przycisk jest trzymany
                    r_auto_repeat_counter <= r_auto_repeat_counter + 1;
                    if r_auto_repeat_counter >= r_current_repeat_interval then
                        if cnt_l = "0000" then
                            cnt_l <= "1001";
                        else
                            cnt_l <= cnt_l - 1;
                        end if;

                        if r_current_repeat_interval > FAST_REPEAT_INTERVAL_CYCLES then
                            r_current_repeat_interval <= r_current_repeat_interval - ACCELERATION_STEP_CYCLES;
                        end if;
                        r_auto_repeat_counter <= 0;
                    end if;
                end if;

                -- Resetuj stan dla lewego przycisku
                l_auto_repeat_counter <= 0;
                l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;

            -- --- �aden przycisk nie jest wci�ni�ty (reset stan�w) ---
            else
                l_auto_repeat_counter <= 0;
                r_auto_repeat_counter <= 0;
                l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                -- sync_timer i waiting_for_second_button zostan� wy��czone, gdy sync_timer dojdzie do 0
                -- lub je�li first_button_pressed jest "00"
            end if;

            -- Zawsze aktualizuj poprzednie stany przycisk�w na koniec cyklu
            btn_l_prev_debounced <= btn_l_debounced;
            btn_r_prev_debounced <= btn_r_debounced;

        end if;
    end process;

    -- Mapowanie licznik�w na dekodery 7-segmentowe
    u1: seg7_decoder port map(bcd => STD_LOGIC_VECTOR(cnt_l), seg => seg_l);
    u2: seg7_decoder port map(bcd => STD_LOGIC_VECTOR(cnt_r), seg => seg_r);

end Behavioral;