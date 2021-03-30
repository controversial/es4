library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dddd is
  port(
    value : in unsigned(5 downto 0);
    tensdigit : out std_logic_vector(6 downto 0);
    onesdigit : out std_logic_vector(6 downto 0)
  );
end dddd;

architecture sim of dddd is
  component sevenseg is
    port(
      S : in unsigned(3 downto 0);
      segments : out std_logic_vector(6 downto 0)
    );
  end component;
  signal lowBCD, highBCD: unsigned(3 downto 0) := "0000";
  signal tensplace: unsigned(12 downto 0) := "0000000000000";
begin
  lowBCD <= value mod "1010";
  tensplace <= value * to_unsigned(52, 7);
  highBCD <= tensplace(12 downto 9);

  low_sevenseg: sevenseg port map(S => lowBCD, segments => onesdigit);
  high_sevenseg: sevenseg port map(S => highBCD, segments => tensdigit);
end;
