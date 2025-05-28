-- menu_top.vhd (bez debounce dla uproszczenia)

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
    signal btn_l_d, btn_r_d : STD_LOGIC;
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
        -- debounce dla przycisków
    debounce_l: debounce port map(clk, btn_l, btn_l_d);
    debounce_r: debounce port map(clk, btn_r, btn_r_d);
    process(clk)
    begin
        if rising_edge(clk) then
            if btn_l_d = '1' then
                if cnt_l = "1001" then
                    cnt_l <= "0000";
                else
                    cnt_l <= cnt_l + 1;
                end if;
            end if;

            if btn_r_d = '1' then
                cnt_r <= cnt_l;
            end if;
        end if;
    end process;

    u1: seg7_decoder port map(cnt_l, seg_l);
    u2: seg7_decoder port map(cnt_r, seg_r);
end Behavioral;
