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

  -- horizontal timings given in pixels
  constant HORIZ_SYNC         : integer := 96;
  constant HORIZ_BACK_PORCH   : integer := 40;
  constant HORIZ_VISIBLE_AREA : integer := 640;
  constant HORIZ_FRONT_PORCH  : integer := 24;
  constant HORIZ_TOTAL        : integer := HORIZ_SYNC + HORIZ_BACK_PORCH + HORIZ_VISIBLE_AREA + HORIZ_FRONT_PORCH;

  -- vertical timings given in lines
  constant VERT_SYNC         : integer := 2;
  constant VERT_BACK_PORCH   : integer := 33;
  constant VERT_VISIBLE_AREA : integer := 480;
  constant VERT_FRONT_PORCH  : integer := 10;
  constant VERT_TOTAL        : integer := VERT_SYNC + VERT_BACK_PORCH + VERT_VISIBLE_AREA + VERT_FRONT_PORCH;
begin
  pll1: pll port map(
    clk_in => clk,
    clk_out => clk_pxl
  );

  hsync <= '0' when col_counter < HORIZ_SYNC else '1';
  vsync <= '0' when row_counter < VERT_SYNC else '1';

  -- Row and col encode pixel positions, only in the visible area
  col_visible <= '1' when ((col_counter >= HORIZ_SYNC + HORIZ_BACK_PORCH) and (col_counter < HORIZ_TOTAL - HORIZ_FRONT_PORCH)) else '0';
  row_visible <= '1' when ((row_counter >= VERT_SYNC + VERT_BACK_PORCH) and (row_counter < VERT_TOTAL - VERT_FRONT_PORCH)) else '0';

  col <= col_counter - (HORIZ_SYNC + HORIZ_BACK_PORCH) when col_visible else "0000000000";
  row <= row_counter - (VERT_SYNC + VERT_BACK_PORCH) when row_visible else "0000000000";

  process(clk_pxl) begin
    if rising_edge(clk_pxl) then
      if col_counter < (HORIZ_TOTAL - 1) then
        col_counter <= col_counter + 1;
      else
        col_counter <= "0000000000";
        if row_counter < (VERT_TOTAL - 1) then
          row_counter <= row_counter + 1;
        else
          row_counter <= "0000000000";
        end if;
      end if;
    end if;

    if falling_edge(clk_pxl) then
      -- Unpack individual pixel values from 6-bit vector
      red1 <= rgb(5) when row_visible and col_visible else '0';
      red0 <= rgb(4) when row_visible and col_visible else '0';
      grn1 <= rgb(3) when row_visible and col_visible else '0';
      grn0 <= rgb(2) when row_visible and col_visible else '0';
      blu1 <= rgb(1) when row_visible and col_visible else '0';
      blu0 <= rgb(0) when row_visible and col_visible else '0';
    end if;
  end process;
end;
