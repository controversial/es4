library IEEE;
use IEEE.std_logic_1164.all;

entity test_7seg is
  port(
    seg_a: out std_logic;
    seg_b: out std_logic;
    seg_c: out std_logic;
    seg_d: out std_logic;
    seg_e: out std_logic;
    seg_f: out std_logic;
    seg_g: out std_logic;

    s_0: in std_logic
  );
end test_7seg;

architecture synth of test_7seg is
begin
  seg_a <= s_0;
  seg_b <= not s_0;
  seg_c <= s_0;
  seg_d <= not s_0;
  seg_e <= s_0;
  seg_f <= not s_0;
  seg_g <= s_0;
end;
