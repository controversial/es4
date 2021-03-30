library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_test is
  port(
    seg_a: out std_logic;
    seg_b: out std_logic;
    seg_c: out std_logic;
    seg_d: out std_logic;
    seg_e: out std_logic;
    seg_f: out std_logic;
    seg_g: out std_logic;

    display_1: out std_logic;
    display_2: out std_logic
  );
end clock_test;

architecture synth of clock_test is
  component SB_HFOSC is
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
  signal counter: unsigned(25 downto 0);
begin

  osc: SB_HFOSC
  generic map(CLKHF_DIV => "0b00")
  port map(
    CLKHFPU => '1',
    CLKHFEN => '1',
    CLKHF => clk
  );
  process(clk) begin
    if rising_edge(clk) then
      counter <= counter + 1;

      display_1 <= counter(24);
      display_2 <= not counter(24);

      seg_a <= counter(25);
      seg_b <= not counter(25);
      seg_c <= counter(25);
      seg_d <= not counter(25);
      seg_e <= counter(25);
      seg_f <= not counter(25);
      seg_g <= counter(25);
    end if;
  end process;
end;
