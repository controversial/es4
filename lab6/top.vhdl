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
begin
  vga_driver: vga port map(
    clk => clk,
    rgb => "000000",
    clk_pxl => vsync,
    -- row => ,
    -- col => ,
    -- Pins of VGA
    red1 => red1,
    red0 => red0,
    grn1 => grn1,
    grn0 => grn0,
    blu1 => blu1,
    blu0 => blu0,
    hsync => hsync
    -- vsync =>
  );
end;
