library IEEE;
use IEEE.std_logic_1164.all;

entity top is

end top;

architecture synth of top is
  component HSOSC is
    generic (
      CLKHF_DIV : String := "0b00" -- Divide 48MHz clock by 2ˆN (0-3)
    );
    port(
      CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
      CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
      CLKHF : out std_logic := 'X' -- Clock output
    );
  end component;
  -- Clock signal
  signal clk: std_logic;
begin
  osc: HSOSC
    generic map(CLKHF_DIV => "0b00")
    port map(
      CLKHFPU => '1',
      CLKHFEN => '1',
      CLKHF => clk
    );
  process(clk) begin
    if rising_edge(clk) then
      -- something here
    end if;
  end process;
end;
