library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- [ADDED] ต้องมี 2 libraries นี้เพื่อใช้คำสั่งเขียนไฟล์และจัดการ Text
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_vga_driver is
-- Test benches have no ports
end tb_vga_driver;

architecture sim of tb_vga_driver is

    -- Component Declaration for the Unit Under Test (UUT)
    component top_pong
        port (
            CLK       : in std_logic;
            reset     : in std_logic;
            buttons   : in std_logic_vector(4 downto 0);
            vga_red   : out std_logic_vector(3 downto 0);
            vga_green : out std_logic_vector(3 downto 0);
            vga_blue  : out std_logic_vector(3 downto 0);
            hsync     : out std_logic;
            vsync     : out std_logic
        );
    end component;

    -- Signals to connect to UUT
    signal clk_100      : std_logic := '0';
    signal reset        : std_logic := '1';
    signal vga_r, vga_g, vga_b : std_logic_vector(3 downto 0);
    signal hsync, vsync : std_logic;
    signal px, py       : unsigned(10 downto 0);
    signal v_on         : std_logic;
    signal rgb_in       : std_logic_vector(11 downto 0) := "000000000000"; -- Default to Black

    -- Clock period definitions (100MHz = 10ns)
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: top_pong
        port map (
            CLK       => clk_100,
            reset     => reset,
            buttons   => "00000",
            vga_red   => vga_r,
            vga_green => vga_g,
            vga_blue  => vga_b,
            hsync     => hsync,
            vsync     => vsync
        );

    -- Clock Process: Generate 100MHz system clock
    clk_process : process
    begin
        clk_100 <= '0';
        wait for clk_period/2;
        clk_100 <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin       
        -- Hold reset for 100ns
        reset <= '1';
        wait for 100 ns;    
        reset <= '0';

        -- Simulation run time: must run for at least one VGA frame (~16.8ms)
        wait for 20 ms; 
        rgb_in <= x"0F0"; -- Switch to Green
        
        wait;
    end process;

    -- [FIXED] File Writing Process for 25MHz Pixel Clock
    -- บันทึกทุกๆ 40 ns (ทุก 4 clock cycles of 100MHz)
    -- เพื่อให้ตรงกับ 25MHz Pixel Clock Rate
    file_logger : process(clk_100)
        file file_pointer : text open write_mode is "C:\Users\books\OneDrive\Desktop\Visualcode\vga_from_fromvivado.txt";
        variable line_el   : line;
        variable clk_counter : integer := 0;
    begin
        if rising_edge(clk_100) then
            clk_counter := clk_counter + 1;
            
            -- บันทึกเฉพาะเมื่อ counter ถึง 4 (ทุกๆ 40ns = 4 x 10ns)
            -- นี้จะให้อัตรา 25MHz ตรงกับ Pixel Clock
            if clk_counter = 4 then
                clk_counter := 0; -- Reset counter
                
                -- 1. เขียนเวลา ตามด้วยเครื่องหมาย : และเครื่องหมายว่าง
                write(line_el, now); 
                write(line_el, string'(": "));

                -- 2. เขียน hsync และ vsync (Binary) คั่นด้วยช่องว่าง
                write(line_el, hsync); 
                write(line_el, string'(" "));
                write(line_el, vsync); 
                write(line_el, string'(" "));

                -- 3. เขียนค่าสี Red, Green, Blue (4-bit Binary)
                write(line_el, vga_r);
                write(line_el, string'(" "));
                write(line_el, vga_g);
                write(line_el, string'(" "));
                write(line_el, vga_b);

                -- 4. บันทึกลงไฟล์
                writeline(file_pointer, line_el);
            end if;
        end if;
    end process;

end sim;
