library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity vga_driver is
  port (
    CLK       : in std_logic;
    -- Note: reset is kept in the port list to avoid breaking your top-level 
    -- entity, but we will "ignore" it inside the logic for auto-start.
    reset     : in std_logic; 

    -- VGA Physical Pins
    vga_red   : out std_logic_vector(3 downto 0);
    vga_green : out std_logic_vector(3 downto 0);
    vga_blue  : out std_logic_vector(3 downto 0);
    hsync     : out std_logic;
    vsync     : out std_logic;

    -- Interface to Game/Logic
    pixel_x  : out unsigned(10 downto 0);
    pixel_y  : out unsigned(10 downto 0);
    video_on : out std_logic;
    
    rgb_in   : in std_logic_vector(11 downto 0) 
  );
end vga_driver;

architecture Behavioral of vga_driver is

  component clk_wiz_0
    port (
      clk_in1  : in std_logic;
      clk_out1 : out std_logic;
      locked   : out std_logic;
      reset    : in STD_LOGIC
    );
  end component;

  signal pixel_clk    : std_logic;
  signal clk_locked   : std_logic;
  signal h_cnt        : unsigned(10 downto 0) := (others => '0');
  signal v_cnt        : unsigned(10 downto 0) := (others => '0');

  constant H_ACTIVE : integer := 640;
  constant H_FP     : integer := 16;
  constant H_SYNC   : integer := 96;
  constant H_BP     : integer := 48;
  constant H_TOTAL  : integer := 800;

  constant V_ACTIVE : integer := 480;
  constant V_FP     : integer := 10;
  constant V_SYNC   : integer := 2;
  constant V_BP     : integer := 33;
  constant V_TOTAL  : integer := 525;

begin

  -- Clock Wizard Instance
  vgs_clk_gen : clk_wiz_0
  port map (
    clk_in1  => CLK,
    clk_out1 => pixel_clk,
    -- Tying reset to '0' ensures the clock starts immediately upon power-up
    -- assuming the Clock Wizard is configured as "Active High" reset.
    reset    => '0', 
    locked   => clk_locked 
  );

  -- Main Sync and Counter Process
  process (pixel_clk)
  begin
    if rising_edge(pixel_clk) then
      -- Auto-start Logic: The system only "resets" if the clock isn't stable.
      -- We removed "reset = '0'" so it no longer waits for the button.
      if clk_locked = '0' then
        h_cnt <= (others => '0');
        v_cnt <= (others => '0');
        hsync <= '1';
        vsync <= '1';
        video_on <= '0';
        vga_red   <= (others => '0');
        vga_green <= (others => '0');
        vga_blue  <= (others => '0');
      else
        -- 1. Increment Counters
        if h_cnt = H_TOTAL - 1 then
          h_cnt <= (others => '0');
          if v_cnt = V_TOTAL - 1 then
            v_cnt <= (others => '0');
          else
            v_cnt <= v_cnt + 1;
          end if;
        else
          h_cnt <= h_cnt + 1;
        end if;

        -- 2. Generate Registered HSYNC
        if (h_cnt >= (H_ACTIVE + H_FP) and h_cnt < (H_ACTIVE + H_FP + H_SYNC)) then
          hsync <= '0';
        else
          hsync <= '1';
        end if;

        -- 3. Generate Registered VSYNC
        if (v_cnt >= (V_ACTIVE + V_FP) and v_cnt < (V_ACTIVE + V_FP + V_SYNC)) then
          vsync <= '0';
        else
          vsync <= '1';
        end if;

        -- 4. Generate Video On Signal and Pixel Coordinates
        if (h_cnt < H_ACTIVE and v_cnt < V_ACTIVE) then
          video_on <= '1';
          vga_red   <= rgb_in(11 downto 8);
          vga_green <= rgb_in(7 downto 4);
          vga_blue  <= rgb_in(3 downto 0);
        else
          video_on <= '0';
          vga_red   <= (others => '0');
          vga_green <= (others => '0');
          vga_blue  <= (others => '0');
        end if;

        pixel_x <= h_cnt;
        pixel_y <= v_cnt;

      end if;
    end if;
  end process;

end Behavioral;