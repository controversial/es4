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
begin
  -- Note: we invert everything because it’s configured as pull-up

  -- Set up 6-bit input number from DP switch inputs
  value <= not inp_5 & not inp_4 & not inp_3 & not inp_2 & not inp_1 & not inp_0;

  -- Decode number
  DDDD_1 : dddd port map(value => value, tensdigit => tensdigit_segments, onesdigit => onesdigit_segments);

  -- Hook up seven-bit number to seven segments
  display_1 <= '1';
  display_2 <= '1';
  seg_a <= onesdigit_segments(6);
  seg_b <= onesdigit_segments(5);
  seg_c <= onesdigit_segments(4);
  seg_d <= onesdigit_segments(3);
  seg_e <= onesdigit_segments(2);
  seg_f <= onesdigit_segments(1);
  seg_g <= onesdigit_segments(0);
end;
