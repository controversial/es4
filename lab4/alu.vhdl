library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
  port(
    a : in unsigned(3 downto 0);
    b : in unsigned(3 downto 0);
    s : in std_logic_vector(1 downto 0);
    y : out unsigned(3 downto 0)
  );
end alu;

architecture synth of alu is
begin
  with s select y <=
    a and b when "00",
    a or b when "01",
    a + b when "10",
    a - b when "11",
    "0000" when others;
end;
