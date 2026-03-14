library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixel_generator is
    Port (
        video_on : in  std_logic;
        pixel_x  : in  unsigned(10 downto 0);
        pixel_y  : in  unsigned(10 downto 0);
        rgb_out  : out std_logic_vector(11 downto 0)
    );
end pixel_generator;

architecture Behavioral of pixel_generator is
    -- Colors (12-bit RGB)
    constant COLOR_BG   : std_logic_vector(11 downto 0) := x"000"; -- Black
    constant COLOR_PAD1 : std_logic_vector(11 downto 0) := x"F00"; -- Red
    constant COLOR_PAD2 : std_logic_vector(11 downto 0) := x"00F"; -- Blue
    constant COLOR_BALL : std_logic_vector(11 downto 0) := x"0F0"; -- Green
    constant COLOR_NET  : std_logic_vector(11 downto 0) := x"FFF"; -- White

    -- Example Object coordinates (Static for now, later you can use signals)
    constant PAD1_X_L : integer := 32;
    constant PAD1_X_R : integer := 40;
    constant PAD1_Y_T : integer := 200;
    constant PAD1_Y_B : integer := 280;

    constant PAD2_X_L : integer := 600;
    constant PAD2_X_R : integer := 608;
    constant PAD2_Y_T : integer := 200;
    constant PAD2_Y_B : integer := 280;

    constant BALL_X_L : integer := 316;
    constant BALL_X_R : integer := 324;
    constant BALL_Y_T : integer := 236;
    constant BALL_Y_B : integer := 244;

    -- Object display signals
    signal pad1_on : std_logic;
    signal pad2_on : std_logic;
    signal ball_on : std_logic;
    signal net_on  : std_logic;

begin

    -- Paddle 1 (Left) Drawing Logic
    pad1_on <= '1' when (TO_INTEGER(pixel_x) >= PAD1_X_L) and 
                        (TO_INTEGER(pixel_x) <= PAD1_X_R) and
                        (TO_INTEGER(pixel_y) >= PAD1_Y_T) and
                        (TO_INTEGER(pixel_y) <= PAD1_Y_B) else
               '0';

    -- Paddle 2 (Right) Drawing Logic
    pad2_on <= '1' when (TO_INTEGER(pixel_x) >= PAD2_X_L) and 
                        (TO_INTEGER(pixel_x) <= PAD2_X_R) and
                        (TO_INTEGER(pixel_y) >= PAD2_Y_T) and
                        (TO_INTEGER(pixel_y) <= PAD2_Y_B) else
               '0';

    -- Ball Drawing Logic
    ball_on <= '1' when (TO_INTEGER(pixel_x) >= BALL_X_L) and 
                        (TO_INTEGER(pixel_x) <= BALL_X_R) and
                        (TO_INTEGER(pixel_y) >= BALL_Y_T) and
                        (TO_INTEGER(pixel_y) <= BALL_Y_B) else
               '0';

    -- Net Drawing Logic (Dashed line in the middle)
    net_on <= '1' when (TO_INTEGER(pixel_x) >= 318) and
                       (TO_INTEGER(pixel_x) <= 321) and
                       (TO_INTEGER(pixel_y) mod 16 < 8) else
              '0';

    -- Coloring Logic (Priority: Ball -> Paddles -> Net -> Background)
    process(video_on, pad1_on, pad2_on, ball_on, net_on)
    begin
        if video_on = '0' then
            rgb_out <= (others => '0'); -- Blank outside display area
        else
            if ball_on = '1' then
                rgb_out <= COLOR_BALL;
            elsif pad1_on = '1' then
                rgb_out <= COLOR_PAD1;
            elsif pad2_on = '1' then
                rgb_out <= COLOR_PAD2;
            elsif net_on = '1' then
                rgb_out <= COLOR_NET;
            else
                rgb_out <= COLOR_BG;
            end if;
        end if;
    end process;

end Behavioral;
