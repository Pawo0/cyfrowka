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
    signal btn_l_d, btn_r_d : STD_LOGIC;
    signal btn_l_prev, btn_r_prev : STD_LOGIC := '0';

    constant HOLD_THRESHOLD : INTEGER := 50000000;    -- 2 s
    constant MIN_INTERVAL   : INTEGER := 12500000;    -- 0.5 s
    constant ACCELERATION_STEP : INTEGER := 6250000;  -- 0.25 s


    component seg7_decoder
        Port (
            bcd : in  STD_LOGIC_VECTOR(3 downto 0);
            seg : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component debounce is
        Port (
            clk     : in  STD_LOGIC;
            btn_in  : in  STD_LOGIC;
            btn_out : out STD_LOGIC
        );
    end component;
begin
    debounce_l: debounce port map(clk => clk, btn_in => btn_l, btn_out => btn_l_d);
    debounce_r: debounce port map(clk => clk, btn_in => btn_r, btn_out => btn_r_d);

    process(clk)
    begin
        if rising_edge(clk) then
            

            --  oba przyciski wcisniete
            if btn_l_d = '1' and btn_r_d = '1' then
                cnt_r <= cnt_l;

            -- LEWY przycisk
            elsif btn_l_d = '1' then
                -- klikni?cie
                if btn_l_prev = '0' then
                    if cnt_l = "1001" then
                        cnt_l <= "0000";
                    else
                        cnt_l <= cnt_l + 1;
                    end if;
                else
                    -- auto-repeat
                    l_counter <= l_counter + 1;
                    if l_counter > l_repeat_interval then
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
                end if;

            -- PRAWY przycisk
            elsif btn_r_d = '1' then
                if btn_r_prev = '0' then
                    if cnt_l = "0000" then
                        cnt_l <= "1001";
                    else
                        cnt_l <= cnt_l - 1;
                    end if;
                else
                    r_counter <= r_counter + 1;
                    if r_counter > r_repeat_interval then
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
                end if;

            -- reset licznikow
            else
                r_counter <= 0;
                r_repeat_interval <= HOLD_THRESHOLD;
                l_counter <= 0;
                l_repeat_interval <= HOLD_THRESHOLD;
            end if;
            btn_l_prev <= btn_l_d;
            btn_r_prev <= btn_r_d;
        end if;

    end process;

    u1: seg7_decoder port map(bcd => cnt_l, seg => seg_l);
    u2: seg7_decoder port map(bcd => cnt_r, seg => seg_r);
end Behavioral;

