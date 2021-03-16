library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
  port(
    -- First input number
    a_3 : in std_logic;
    a_2 : in std_logic;
    a_1 : in std_logic;
    a_0 : in std_logic;
    -- Second input number
    b_3 : in std_logic;
    b_2 : in std_logic;
    b_1 : in std_logic;
    b_0 : in std_logic;
    -- ALU operator selection
    s_1 : in std_logic;
    s_0 : in std_logic;
    -- Debug output with onboard LED
    seg_a : out std_logic;
    seg_b : out std_logic;
    seg_c : out std_logic;
    seg_d : out std_logic;
    seg_e : out std_logic;
    seg_f : out std_logic;
    seg_g : out std_logic
  );
end top;


architecture synth of top is
  -- For performing addition operations
  component alu
    port(
      a : in unsigned(3 downto 0);
      b : in unsigned(3 downto 0);
      s : in std_logic_vector(1 downto 0);
      y : out unsigned(3 downto 0)
    );
  end component;
  -- For encoding 4-bit numbers on the seven-segment display.
  component sevenseg
    port(
      S : in unsigned(3 downto 0);
      segments : out std_logic_vector(6 downto 0)
    );
  end component;

  signal a : unsigned(3 downto 0);
  signal b : unsigned(3 downto 0);
  signal s : std_logic_vector(1 downto 0);
  signal alu_result : unsigned(3 downto 0);
  signal segments : std_logic_vector(6 downto 0);
begin
  -- Note: we invert everything because it’s configured as pull-up

  -- Set up signal 4-bit number “a” from DP switch inputs
  a(3) <= not a_3;
  a(2) <= not a_2;
  a(1) <= not a_1;
  a(0) <= not a_0;
  -- Set up signal 4-bit number “b” from DP switch inputs
  b(3) <= not b_3;
  b(2) <= not b_2;
  b(1) <= not b_1;
  b(0) <= not b_0;
  -- Set up signal 2-bit number “s” from push button inputs
  s(1) <= not s_1;
  s(0) <= not s_0;

  -- Connect ALU and seven-segment decoder
  ALU_1: alu port map(a => a, b => b, s => s, y => alu_result);
  SEVENSEG_1: sevenseg port map(S => alu_result, segments => segments);

  -- Hook up seven-segment decoder component to display pins
  seg_a <= segments(6);
  seg_b <= segments(5);
  seg_c <= segments(4);
  seg_d <= segments(3);
  seg_e <= segments(2);
  seg_f <= segments(1);
  seg_g <= segments(0);
end;
