library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
  port(
    -- Input number
    inp_5 : in std_logic;
    inp_4 : in std_logic;
    inp_3 : in std_logic;
    inp_2 : in std_logic;
    inp_1 : in std_logic;
    inp_0 : in std_logic;

    -- Output display
    seg_a : out std_logic;
    seg_b : out std_logic;
    seg_c : out std_logic;
    seg_d : out std_logic;
    seg_e : out std_logic;
    seg_f : out std_logic;
    seg_g : out std_logic;
    display_1 : out std_logic;
    display_2 : out std_logic
  );
end top;


architecture synth of top is
  -- Clock
  component SB_HFOSC is
    generic (CLKHF_DIV : String := "0b00");
    port(
      CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
      CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
      CLKHF : out std_logic := 'X' -- Clock output
    );
  end component;
  signal clk: std_logic;

  -- Dual digit decimal driver
  component dddd is
    port(
      value : in unsigned(5 downto 0);
      tensdigit : out std_logic_vector(6 downto 0);
      onesdigit : out std_logic_vector(6 downto 0)
    );
  end component;
  signal value : unsigned(5 downto 0);
  signal tensdigit_segments : std_logic_vector(6 downto 0);
  signal onesdigit_segments : std_logic_vector(6 downto 0);
  signal display_tens : std_logic := '0';
begin
  -- Initialize clock
  osc: SB_HFOSC
    generic map(CLKHF_DIV => "0b00")
    port map(CLKHFPU => '1', CLKHFEN => '1', CLKHF => clk);

  -- Set up 6-bit input number from DP switch inputs
  -- Note: we invert everything because it’s configured as pull-up
  value <= not inp_5 & not inp_4 & not inp_3 & not inp_2 & not inp_1 & not inp_0;

  -- Decode number
  DDDD_1 : dddd port map(value => value, tensdigit => tensdigit_segments, onesdigit => onesdigit_segments);

  -- Hook up seven-bit number to seven segments
  display_1 <= display_tens;
  display_2 <= not display_tens;
  process(clk) begin
    if rising_edge(clk) then
      -- Display either ones digit or tens digit depending on which display is powered
      -- Note: if we have display_tens = '1', that means it's about to flip to zero, so we should
      --       display the ones digit, not the tens digit.
      if display_tens = '1' then
        seg_a <= onesdigit_segments(6);
        seg_b <= onesdigit_segments(5);
        seg_c <= onesdigit_segments(4);
        seg_d <= onesdigit_segments(3);
        seg_e <= onesdigit_segments(2);
        seg_f <= onesdigit_segments(1);
        seg_g <= onesdigit_segments(0);
      else
        seg_a <= tensdigit_segments(6);
        seg_b <= tensdigit_segments(5);
        seg_c <= tensdigit_segments(4);
        seg_d <= tensdigit_segments(3);
        seg_e <= tensdigit_segments(2);
        seg_f <= tensdigit_segments(1);
        seg_g <= tensdigit_segments(0);
      end if;
      -- Flip which display is powered
      display_tens <= not display_tens;
    end if;
  end process;
end;
