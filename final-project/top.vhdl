library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
  port(
    -- VGA signals
    red0, red1, grn0, grn1, blu0, blu1 : out std_logic;
    hsync, vsync : out std_logic;
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
      frame_count : in unsigned(17 downto 0);

      rgb : out std_logic_vector(5 downto 0)
    );
  end component;

  signal clk_pxl : std_logic;
  signal row, col : unsigned(9 downto 0);
  signal rgb : std_logic_vector(5 downto 0) := "000000";

  signal frame_count : unsigned(17 downto 0); -- 2^18 frames > 216000 frames = 3600 seconds = 1 hour
begin
  vga_driver: vga port map(
    clk => clk,
    rgb => rgb,
    clk_pxl => clk_pxl,
    row => row,
    col => col,

    -- Outputs to pins of VGA breakout
    red1 => red1,
    red0 => red0,
    grn1 => grn1,
    grn0 => grn0,
    blu1 => blu1,
    blu0 => blu0,
    hsync => hsync,
    vsync => vsync
  );

  process(clk_pxl) begin
    -- Run once per frame: check that we're at a specific coordinate
    if rising_edge(clk_pxl) and row = 1 and col = 1 then
      frame_count <= frame_count + 1;
    end if;
  end process;

  game_render: game_renderer port map(
    frame_count => frame_count,
    row => row,
    col => col,
    rgb => rgb
  );
end;
