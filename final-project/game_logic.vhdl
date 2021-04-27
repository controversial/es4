library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_logic is
  port(
    btn_up, btn_down, btn_right, btn_left : in std_logic;
    clk : in std_logic; game_clock : in std_logic;

  );
end game_logic;

architecture synth of game_logic is
  signal direction : std_logic_vector(1 downto 0) := "11";
begin
  process(clk) begin
    if rising_edge(clk) then
      if btn_up = '1' then direction <= "00";
      elsif btn_down = '1' then direction <= "01";
      elsif btn_left = '1' then direction <= "10";
      elsif btn_right = '1' then direction <= "11";
      end if;
    end if;
  end process;

end;
