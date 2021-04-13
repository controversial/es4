-- adapted from Michael Reigert’s https://github.com/nobodywasishere/upduino-projects/blob/master/vga/vga.vhdl

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pll is
  port (
    clk_in : in std_logic; -- reference input clock (12M)
    clk_out : out std_logic -- output clock (25.125 MHz)
  );
end pll;

architecture synth of pll is
  component SB_PLL40_CORE is
    generic (
      -- 48 MHz -> 25.125 MHz (480p)
      FEEDBACK_PATH : String := "SIMPLE";
      DIVR : unsigned(3 downto 0) := "0011";
      DIVF : unsigned(6 downto 0) := "1000010";
      DIVQ : unsigned(2 downto 0) := "101";
      FILTER_RANGE : unsigned(2 downto 0) := "001"
    );
    port (
      LOCK : out std_logic;
      RESETB : in std_logic;
      BYPASS : in std_logic;
      REFERENCECLK : in std_logic;
      PLLOUTGLOBAL : out std_logic
    );
  end component;
begin
  dut1 : SB_PLL40_CORE port map (
    LOCK => open,
    RESETB => '1',
    BYPASS => '0',
    REFERENCECLK => clk_in,
    PLLOUTGLOBAL => clk_out
  );
end;
