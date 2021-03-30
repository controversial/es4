library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_test is
  port(
    seg_1a: out std_logic;
    seg_1b: out std_logic;
    seg_1c: out std_logic;
    seg_1d: out std_logic;
    seg_1e: out std_logic;
    seg_1f: out std_logic;
    seg_1g: out std_logic;

    seg_2a: out std_logic;
    seg_2b: out std_logic;
    seg_2c: out std_logic;
    seg_2d: out std_logic;
    seg_2e: out std_logic;
    seg_2f: out std_logic;
    seg_2g: out std_logic
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
      seg_1a <= counter(25);
      seg_1b <= not counter(25);
      seg_1c <= counter(25);
      seg_1d <= not counter(25);
      seg_1e <= counter(25);
      seg_1f <= not counter(25);
      seg_1g <= counter(25);

      seg_2a <= not counter(25);
      seg_2b <= counter(25);
      seg_2c <= not counter(25);
      seg_2d <= counter(25);
      seg_2e <= not counter(25);
      seg_2f <= counter(25);
      seg_2g <= not counter(25);
    end if;
  end process;
end;
