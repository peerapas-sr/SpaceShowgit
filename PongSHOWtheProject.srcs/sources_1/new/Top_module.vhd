library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_pong is
    Port ( 
        CLK       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        buttons : in std_logic_vector(4 downto 0);
        -- Physical VGA Pins

        vga_red   : out STD_LOGIC_VECTOR (3 downto 0);
        vga_green : out STD_LOGIC_VECTOR (3 downto 0);
        vga_blue  : out STD_LOGIC_VECTOR (3 downto 0);
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC
        
    );
end top_pong;

architecture Behavioral of top_pong is
    -- Internal signals to connect driver to game logic
    signal w_pixel_x  : unsigned(10 downto 0);
    signal w_pixel_y  : unsigned(10 downto 0);
    signal w_video_on : std_logic;
    signal w_rgb_in   : std_logic_vector(11 downto 0);

begin
    -- 1. Instantiate the VGA Driver
    VGA_GEN: entity work.vga_driver
        port map (
            CLK       => CLK,
            reset     => reset,
            vga_red   => vga_red,
            vga_green => vga_green,
            vga_blue  => vga_blue,
            hsync     => hsync,
            vsync     => vsync,
            pixel_x   => w_pixel_x,
            pixel_y   => w_pixel_y,
            video_on  => w_video_on,
            rgb_in    => w_rgb_in
        );
    -- 2. Instantiate the Pixel Generator
    PIXEL_GEN: entity work.pixel_generator
        port map (
            video_on => w_video_on,
            pixel_x  => w_pixel_x,
            pixel_y  => w_pixel_y,
            rgb_out  => w_rgb_in
        );


end Behavioral;