library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
  port(
    -- VGA signals
    red0, red1, grn0, grn1, blu0, blu1 : out std_logic;
    hsync, vsync : out std_logic;

    btn_up, btn_down, btn_left, btn_right : in std_logic;

    clk : in std_logic
  );
end top;

architecture synth of top is
  component vga is
    port(
      clk : in std_logic;
      rgb : in std_logic_vector(5 downto 0);
      clk_pxl : out std_logic;
      row, col : out unsigned(9 downto 0);
      red1, red0, grn1, grn0, blu1, blu0 : out std_logic;
      hsync, vsync : out std_logic
    );
  end component;

  component game_renderer is
    port(
      row, col : in unsigned(9 downto 0);

      rgb : out std_logic_vector(5 downto 0)
    );
  end component;

  component game_logic is
    port(
      btn_up, btn_down, btn_right, btn_left : in std_logic;
      clk : in std_logic; game_clock : in std_logic
    );
  end component;

  signal pixel_clock : std_logic;
  signal row, col : unsigned(9 downto 0);
  signal rgb : std_logic_vector(5 downto 0) := "000000";

  signal frame_count : unsigned(3 downto 0);
  signal game_clock : std_logic;
begin
  vga_driver: vga port map(
    clk => clk, -- input 12M

    clk_pxl => pixel_clock, -- output clock per pixel
    row => row, col => col, -- output current block pos

    rgb => rgb, -- input RGB

    -- Outputs to pins of VGA breakout
    red1 => red1, red0 => red0, grn1 => grn1, grn0 => grn0, blu1 => blu1, blu0 => blu0,
    hsync => hsync, vsync => vsync
  );

  process(pixel_clock) begin
    -- Run once per frame: check that we're at a specific coordinate
    if rising_edge(pixel_clock) and row = 1 and col = 1 then
      frame_count <= frame_count + 1;
    end if;
  end process;
  -- Every 32 frames, we update the game
  game_clock <= '1' when frame_count = "1111" else '0';

  game_render: game_renderer port map(
    row => row,
    col => col,
    rgb => rgb
  );

  game_logic_a : game_logic port map(
    btn_up => not btn_up, btn_down => not btn_down, btn_left => not btn_left, btn_right => not btn_right,
    clk => clk, game_clock => game_clock
  );
end;
