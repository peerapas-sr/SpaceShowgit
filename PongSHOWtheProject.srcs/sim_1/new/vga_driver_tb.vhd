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
    component vga_driver
        port (
            CLK       : in std_logic;
            reset     : in std_logic;
            vga_red   : out std_logic_vector(3 downto 0);
            vga_green : out std_logic_vector(3 downto 0);
            vga_blue  : out std_logic_vector(3 downto 0);
            hsync     : out std_logic;
            vsync     : out std_logic;
            pixel_x   : out unsigned(10 downto 0);
            pixel_y   : out unsigned(10 downto 0);
            video_on  : out std_logic;
            rgb_in    : in std_logic_vector(11 downto 0)
        );
    end component;

    -- Signals to connect to UUT
    signal clk_100      : std_logic := '0';
    signal reset        : std_logic := '1';
    signal vga_r, vga_g, vga_b : std_logic_vector(3 downto 0);
    signal hsync, vsync : std_logic;
    signal px, py       : unsigned(10 downto 0);
    signal v_on         : std_logic;
    signal rgb_in       : std_logic_vector(11 downto 0) := x"F00"; -- Default to Red

    -- Clock period definitions (100MHz = 10ns)
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: vga_driver
        port map (
            CLK       => clk_100,
            reset     => reset,
            vga_red   => vga_r,
            vga_green => vga_g,
            vga_blue  => vga_b,
            hsync     => hsync,
            vsync     => vsync,
            pixel_x   => px,
            pixel_y   => py,
            video_on  => v_on,
            rgb_in    => rgb_in
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

        -- Simulation run time
        wait for 1 ms; 
        rgb_in <= x"0F0"; -- Switch to Green
        
        wait;
    end process;

    -- [ADDED] File Writing Process
    -- กระบวนการบันทึกค่าสัญญาณลงในไฟล์ write.txt ทุกๆ Rising Edge ของ Clock
    -- [UPDATED] File Writing Process for specific format: time units: hs vs red green blue
   -- Process บันทึกไฟล์ Log ทุก Rising Edge ของ Clock (Oversampling)
   -- [UPDATED] File Writing Process: บันทึกทุกๆ 20 ns (ทุก 2 clock cycles)
   -- Process บันทึกไฟล์ Log ตาม Format: current_sim_time time_units: hs vs red green blue
    file_logger : process(clk_100)
        file file_pointer : text open write_mode is "vga_log.txt";
        variable line_el   : line;
        -- ตัวแปรช่วยเพื่อให้บันทึกทุกๆ 20 ns (เว้นจังหวะจาก 100MHz)
        variable log_step  : boolean := false; 
    begin
        if rising_edge(clk_100) then
            -- บันทึกเฉพาะรอบที่ log_step เป็น true (ทุกๆ 2 รอบของ 10ns = 20ns)
            if log_step then
                -- 1. เขียนเวลาและหน่วย (เช่น 535 ns) ตามด้วยเครื่องหมาย :
                write(line_el, now); 
                write(line_el, string'(": ")); -- ใส่ string' เพื่อความชัดเจนของ Syntax

                -- 2. เขียน hsync และ vsync (Binary) คั่นด้วยช่องว่าง
                write(line_el, hsync); 
                write(line_el, string'(" "));
                write(line_el, vsync); 
                write(line_el, string'(" "));

                -- 3. เขียนค่าสี Red, Green, Blue (Binary) 
                -- บน Nexys A7 สัญญาณเหล่านี้จะเป็น 4 บิต ซึ่งจะถูกเขียนเป็นเลขฐานสอง 4 หลักอัตโนมัติ
                write(line_el, vga_r); -- หรือ Red ตามชื่อในโค้ดคุณ
                write(line_el, string'(" "));
                write(line_el, vga_g); -- หรือ Green
                write(line_el, string'(" "));
                write(line_el, vga_b); -- หรือ Blue

                -- 4. บันทึกลงไฟล์
                writeline(file_pointer, line_el);
            end if;

            -- สลับสถานะเพื่อให้บันทึกรอบเว้นรอบ (10ns -> 20ns)
            log_step := not log_step;
        end if;
    end process;
end sim;