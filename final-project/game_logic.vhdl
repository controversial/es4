library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_logic is
  port(
    btn_up, btn_down, btn_right, btn_left : in std_logic;
    clk : in std_logic; game_clock : in std_logic;

    is_up, is_down, is_left, is_right : out std_logic
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

  is_up <= '1' when direction = "00" else '0';
  is_down <= '1' when direction = "01" else '0';
  is_left <= '1' when direction = "10" else '0';
  is_right <= '1' when direction = "11" else '0';
end;
