library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is
  port(
    -- Take in: board’s clock signal, color to display
    clk : in std_logic;
    rgb : in std_logic_vector(5 downto 0);

    -- Output: clock in terms of pixels, current position
    clk_pxl : out std_logic;
    row, col : out unsigned(9 downto 0);

    -- Output: signals to route to pins
    red1, red0, grn1, grn0, blu1, blu0 : out std_logic;
    hsync, vsync : out std_logic
  );
end vga;

architecture synth of vga is
  component pll is
    port (
      clk_in : in std_logic;
      clk_out : out std_logic
    );
  end component;
begin
  pll1: pll port map(
    clk_in => clk,
    clk_out => clk_pxl
  );

  row <= "0000000000";
  col <= "0000000000";
  red1 <= '0';
  red0 <= '0';
  grn1 <= '0';
  grn0 <= '0';
  blu1 <= '0';
  blu0 <= '0';
  hsync <= '0';
  vsync <= '0';
end;
