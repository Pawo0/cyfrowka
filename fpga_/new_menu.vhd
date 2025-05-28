-- menu_top.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity menu_top is
    Port (
        clk     : in  STD_LOGIC;
        btn_l   : in  STD_LOGIC;
        btn_r   : in  STD_LOGIC;
        seg_l   : out STD_LOGIC_VECTOR (6 downto 0);
        seg_r   : out STD_LOGIC_VECTOR (6 downto 0)
    );
end menu_top;

architecture Behavioral of menu_top is
    signal cnt_l   : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal cnt_r   : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal l_counter : INTEGER := 0;
    signal r_counter : INTEGER := 0;
    signal l_repeat_interval : INTEGER := 1000000;
    signal r_repeat_interval : INTEGER := 1000000;

    constant HOLD_THRESHOLD : INTEGER := 1000000;  -- próg rozpoczęcia auto-repeat
    constant MIN_INTERVAL   : INTEGER := 200000;   -- maksymalna szybkość powtarzania
    constant ACCELERATION_STEP : INTEGER := 50000; -- przyspieszenie co krok

    signal btn_l_prev : STD_LOGIC := '0';
    signal btn_r_prev : STD_LOGIC := '0';

    component seg7_decoder
        Port (
            bcd : in  STD_LOGIC_VECTOR(3 downto 0);
            seg : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            -- Auto-repeat left button (increment)
            if btn_l = '1' then
                l_counter <= l_counter + 1;
                if l_counter = 1 or l_counter > l_repeat_interval then
                    if cnt_l = "1001" then
                        cnt_l <= "0000";
                    else
                        cnt_l <= cnt_l + 1;
                    end if;

                    if l_repeat_interval > MIN_INTERVAL then
                        l_repeat_interval <= l_repeat_interval - ACCELERATION_STEP;
                    end if;

                    l_counter <= 0;
                end if;
            else
                l_counter <= 0;
                l_repeat_interval <= HOLD_THRESHOLD;
            end if;

            -- Auto-repeat right button (decrement)
            if btn_r = '1' then
                r_counter <= r_counter + 1;
                if r_counter = 1 or r_counter > r_repeat_interval then
                    if cnt_l = "0000" then
                        cnt_l <= "1001";
                    else
                        cnt_l <= cnt_l - 1;
                    end if;

                    if r_repeat_interval > MIN_INTERVAL then
                        r_repeat_interval <= r_repeat_interval - ACCELERATION_STEP;
                    end if;

                    r_counter <= 0;
                end if;
            else
                r_counter <= 0;
                r_repeat_interval <= HOLD_THRESHOLD;
            end if;

            -- Zatwierdzenie: oba przyciski jednocześnie
            if btn_l = '1' and btn_r = '1' then
                cnt_r <= cnt_l;
            end if;
        end if;
    end process;

    u1: seg7_decoder port map(cnt_l, seg_l);
    u2: seg7_decoder port map(cnt_r, seg_r);
end Behavioral;
