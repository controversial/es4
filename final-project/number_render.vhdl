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
            "000011" & "000111" & "001111" & "110011" & "111111" & "000011" & "000011" when number = 4d"4" else
            "111111" & "110000" & "111110" & "000011" & "000011" & "110011" & "011110" when number = 4d"5" else
            "011110" & "110011" & "110000" & "111110" & "110011" & "110011" & "011110" when number = 4d"6" else
            "111111" & "110011" & "000110" & "001100" & "001100" & "001100" & "001100" when number = 4d"7" else
            "011110" & "110011" & "110011" & "011110" & "110011" & "110011" & "011110" when number = 4d"8" else
            "011110" & "110011" & "110011" & "011111" & "000011" & "110011" & "011110" when number = 4d"9" else
            "000000000000000000000000000000000000000000";

  pos <= to_integer(row) * 6 + to_integer(col);
  pixel <= bitmap(pos);
end;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity triple_digit_decoder is
  port(
    number : in unsigned(9 downto 0);
    hundreds : out unsigned(3 downto 0);
    tens : out unsigned(3 downto 0);
    ones : out unsigned(3 downto 0);
    clock : in std_logic
  );
end triple_digit_decoder;

architecture synth of triple_digit_decoder is
  signal temp1 : unsigned(15 downto 0);
  signal temp2 : unsigned(6 downto 0);
  signal temp3 : unsigned(12 downto 0);
  signal temp4 : unsigned(3 downto 0);
begin
  process (clock) begin
    if rising_edge(clock) then
      ones <= number mod 4d"10";

      temp1 <= number * 6d"52";
      temp2 <= temp1(15 downto 9);
      tens <= temp2 mod 4d"10";

      temp3 <= temp2 * 6d"52";
      temp4 <= temp3(12 downto 9);
      hundreds <= temp4 mod 4d"10";
    end if;
  end process;

end;
