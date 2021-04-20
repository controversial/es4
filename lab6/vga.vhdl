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

  signal col_counter : unsigned(9 downto 0) := "0000000000";
  signal row_counter : unsigned(9 downto 0) := "0000000000";
  signal row_visible : std_logic;
  signal col_visible : std_logic;
begin
  pll1: pll port map(
    clk_in => clk,
    clk_out => clk_pxl
  );

  process(clk_pxl) begin
    if rising_edge(clk) then
      if col_counter < (96 + 48 + 640 + 16) then
        col_counter <= col_counter + 1;
      else
        col_counter <= "0000000000";
        row_counter <= row_counter + 1 when row_counter < (2 + 33 + 480 + 10) else "0000000000";
      end if;
    end if;
  end process;

  hsync <= '1' when col_counter < 96 else '0';
  vsync <= '1' when row_counter < 2 else '0';

  -- Row and col encode pixel positions, only in the visible area
  row_visible <= '1' when ((row_counter >= 2 + 33) and (row_counter < 2 + 33 + 480)) else '0';
  col_visible <= '1' when ((col_counter >= 96 + 48) and (col_counter < 96 + 48 + 640)) else '0';

  row <= row_counter - (2 + 33) when row_visible else "0000000000";
  col <= col_counter - (96 + 48) when col_visible else "0000000000";

  -- Unpack individual pixel values from 6-bit vector
  red1 <= rgb(5) when row_visible and col_visible else '0';
  red0 <= rgb(4) when row_visible and col_visible else '0';
  grn1 <= rgb(3) when row_visible and col_visible else '0';
  grn0 <= rgb(2) when row_visible and col_visible else '0';
  blu1 <= rgb(1) when row_visible and col_visible else '0';
  blu0 <= rgb(0) when row_visible and col_visible else '0';
end;
