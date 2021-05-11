library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity number_render is
  port(
    number : in unsigned(3 downto 0); -- 0 through 9
    row : in unsigned(2 downto 0); -- 0 through 6
    col : in unsigned(2 downto 0); -- 0 through 5
    pixel : out std_logic
  );
end number_render;

architecture synth of number_render is
  signal bitmap : unsigned(0 to 41);
  signal pos : integer;
begin
  bitmap <= "011110110011110111111011110011110011011110" when number = 4d"0" else
            "001100001100011100001100001100001100111111" when number = 4d"1" else
            "011110110011000011000110011000110000111111" when number = 4d"2" else
            "011110110011000011001110000011110011011110" when number = 4d"3" else
            "000011" & "000111" & "001111" & "110011" & "111111" & "000110" & "000110" when number = 4d"4" else
            "111111" & "110000" & "111110" & "000011" & "000011" & "110011" & "011110" when number = 4d"5" else
            "011110" & "110011" & "110000" & "111110" & "110011" & "110011" & "011110" when number = 4d"6" else
            "111111" & "110011" & "000110" & "001100" & "001100" & "001100" & "001100" when number = 4d"7" else
            "011110" & "110011" & "110011" & "011110" & "110011" & "110011" & "011110" when number = 4d"8" else
            "011110" & "110011" & "110011" & "011111" & "000011" & "110011" & "011110" when number = 4d"9" else
            "000000000000000000000000000000000000000000";

  pos <= to_integer(row) * 6 + to_integer(col);
  pixel <= bitmap(pos);
end;
