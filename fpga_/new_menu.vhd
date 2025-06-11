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

    -- Sygna³y po debouncingu
    signal btn_l_debounced, btn_r_debounced : STD_LOGIC;
    -- Poprzednie stany po debouncingu do wykrywania zboczy
    signal btn_l_prev_debounced, btn_r_prev_debounced : STD_LOGIC := '1';

    -- Auto-repeat
    signal l_auto_repeat_counter : INTEGER := 0;
    signal r_auto_repeat_counter : INTEGER := 0;
    signal l_current_repeat_interval : INTEGER;
    signal r_current_repeat_interval : INTEGER;

    -- Logika "podwójnego klikniêcia" lub synchronizacji dwóch przycisków
    signal sync_timer : INTEGER := 0;
    -- Sygnalizuje, ¿e jeden przycisk jest wciœniêty i czekamy na drugi
    signal waiting_for_second_button : BOOLEAN := FALSE;
    -- Zapisuje, który przycisk by³ pierwszy wciœniêty
    signal first_button_pressed : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- "01" dla L, "10" dla R, "00" dla brak

    -- Sta³e czasowe (dostosuj do czêstotliwoœci zegara FPGA)
    constant CLK_FREQ_HZ       : REAL := 25.175e6; -- Przyk³adowa czêstotliwoœæ 25.175 MHz

    -- Auto-repeat timings
    constant INITIAL_REPEAT_DELAY_CYCLES : INTEGER := INTEGER(0.5 * CLK_FREQ_HZ); -- 0.5 sekundy opóŸnienia przed pierwszym auto-repeat
    constant FAST_REPEAT_INTERVAL_CYCLES : INTEGER := INTEGER(0.125 * CLK_FREQ_HZ); -- 0.125 sekundy interwa³ szybki
    constant ACCELERATION_STEP_CYCLES    : INTEGER := INTEGER(0.025 * CLK_FREQ_HZ); -- Przyspieszenie co 0.025 sekundy

    -- Two-button sync timing
    constant TWO_BUTTON_SYNC_TIMEOUT_CYCLES : INTEGER := INTEGER(0.05 * CLK_FREQ_HZ); -- 50 ms na wciœniêcie drugiego przycisku

    -- Komponenty zewnêtrzne (zak³adamy, ¿e s¹ zdefiniowane w osobnych plikach)
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
            btn_out   : out STD_LOGIC; -- Zwykle jest to sygna³ pulsuj¹cy po wciœniêciu/zwolnieniu
            btn_state : out STD_LOGIC  -- Stabilny stan przycisku (0 wciœniêty, 1 zwolniony)
        );
    end component;

begin
    -- Instancjonowanie modu³ów debounce
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

            -- Inicjalizacja interwa³ów auto-repeat (tylko raz na pocz¹tku)
            if l_current_repeat_interval = 0 then
               l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
               r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
            end if;

            -- Logika timera synchronizacji dwóch przycisków
            if sync_timer > 0 then
                sync_timer <= sync_timer - 1;
            else
                waiting_for_second_button <= FALSE; -- Czas min¹³, nie czekamy ju¿ na drugi przycisk
                first_button_pressed <= "00"; -- Resetuj informacjê o pierwszym wciœniêtym przycisku
            end if;

            -- --- Priorytet 1: Oba przyciski wciœniête ---
            if btn_l_debounced = '0' and btn_r_debounced = '0' then
                cnt_r <= cnt_l; -- Kopiowanie wartoœci (to jest akcja dla obu przycisków)

                -- Resetuj wszystkie liczniki i flagi, aby po puszczeniu nie by³o niechcianych akcji
                l_auto_repeat_counter <= 0;
                r_auto_repeat_counter <= 0;
                l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                sync_timer <= 0;
                waiting_for_second_button <= FALSE;
                first_button_pressed <= "00";

            -- --- Priorytet 2: Lewy przycisk jest wciœniêty, prawy zwolniony ---
            elsif btn_l_debounced = '0' and btn_r_debounced = '1' then
                -- Wykrycie zbocza opadaj¹cego (pierwsze naciœniêcie lewego przycisku)
                if btn_l_prev_debounced = '1' then
                    -- Aktywuj timer synchronizacji, jeœli jeszcze nie jest aktywny
                    if not waiting_for_second_button then
                        sync_timer <= TWO_BUTTON_SYNC_TIMEOUT_CYCLES;
                        waiting_for_second_button <= TRUE;
                        first_button_pressed <= "01"; -- Zapamiêtaj, ¿e L by³ pierwszy
                    end if;
                    -- Poczekaj na wygaœniêcie timera lub wciœniêcie drugiego.
                    l_auto_repeat_counter <= 1; -- Ustaw na 1, aby po wygaœniêciu timera by³o gotowe do auto-repeat
                    l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES; -- Reset interwa³u
                end if;

                -- Jeœli czekaliœmy na drugi przycisk (prawy), i ten czas up³yn¹³
                if waiting_for_second_button = TRUE and sync_timer = 0 and first_button_pressed = "01" then
                    -- Tylko wtedy, gdy to by³ faktycznie pierwszy przycisk i okno synchronizacji wygas³o
                    if cnt_l = "1001" then
                        cnt_l <= "0000";
                    else
                        cnt_l <= cnt_l + 1;
                    end if;
                    waiting_for_second_button <= FALSE; -- Operacja wykonana, resetuj
                    first_button_pressed <= "00";
                end if;

                -- Logika auto-repeat (tylko jeœli nie czekamy na drugi przycisk lub okno wygas³o)
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

            -- --- Priorytet 3: Prawy przycisk jest wciœniêty, lewy zwolniony ---
            elsif btn_r_debounced = '0' and btn_l_debounced = '1' then
                -- Wykrycie zbocza opadaj¹cego (pierwsze naciœniêcie prawego przycisku)
                if btn_r_prev_debounced = '1' then
                    if not waiting_for_second_button then
                        sync_timer <= TWO_BUTTON_SYNC_TIMEOUT_CYCLES;
                        waiting_for_second_button <= TRUE;
                        first_button_pressed <= "10"; -- Zapamiêtaj, ¿e R by³ pierwszy
                    end if;
                    r_auto_repeat_counter <= 1;
                    r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                end if;

                -- Jeœli czekaliœmy na drugi przycisk (lewy), i ten czas up³yn¹³
                if waiting_for_second_button = TRUE and sync_timer = 0 and first_button_pressed = "10" then
                    if cnt_l = "0000" then
                        cnt_l <= "1001";
                    else
                        cnt_l <= cnt_l - 1;
                    end if;
                    waiting_for_second_button <= FALSE;
                    first_button_pressed <= "00";
                end if;

                -- Logika auto-repeat (tylko jeœli nie czekamy na drugi przycisk lub okno wygas³o)
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

            -- --- ¯aden przycisk nie jest wciœniêty (reset stanów) ---
            else
                l_auto_repeat_counter <= 0;
                r_auto_repeat_counter <= 0;
                l_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                r_current_repeat_interval <= INITIAL_REPEAT_DELAY_CYCLES;
                -- sync_timer i waiting_for_second_button zostan¹ wy³¹czone, gdy sync_timer dojdzie do 0
                -- lub jeœli first_button_pressed jest "00"
            end if;

            -- Zawsze aktualizuj poprzednie stany przycisków na koniec cyklu
            btn_l_prev_debounced <= btn_l_debounced;
            btn_r_prev_debounced <= btn_r_debounced;

        end if;
    end process;

    -- Mapowanie liczników na dekodery 7-segmentowe
    u1: seg7_decoder port map(bcd => STD_LOGIC_VECTOR(cnt_l), seg => seg_l);
    u2: seg7_decoder port map(bcd => STD_LOGIC_VECTOR(cnt_r), seg => seg_r);

end Behavioral;