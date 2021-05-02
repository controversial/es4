library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_logic is
  port(
    btn_up, btn_down, btn_right, btn_left : in std_logic;
    clk : in std_logic; game_clock : in std_logic;

    snake_head_pos : in std_logic_vector(11 downto 0);
    snake_next_head : out std_logic_vector(11 downto 0)
  );
end game_logic;

architecture synth of game_logic is
  signal direction : std_logic_vector(1 downto 0) := "11";
  signal snake_head_row : unsigned(5 downto 0);
  signal snake_head_col : unsigned(5 downto 0);

  signal snake_next_head_row : unsigned(5 downto 0) := 6d"0";
  signal snake_next_head_col : unsigned(5 downto 0) := 6d"0";
begin
  -- Unpack row/col of current head pos
  snake_head_row <= unsigned(snake_head_pos(11 downto 6));
  snake_head_col <= unsigned(snake_head_pos(5 downto 0));
  -- Pack row/col of next head pos
  snake_next_head <= std_logic_vector(snake_next_head_row) & std_logic_vector(snake_next_head_col);

  process(clk) begin
    if rising_edge(clk) then
      if btn_up = '1' then direction <= "00";
      elsif btn_down = '1' then direction <= "01";
      elsif btn_left = '1' then direction <= "10";
      elsif btn_right = '1' then direction <= "11";
      end if;
    end if;
  end process;

  -- Move snake based on direction
  snake_next_head_row <= snake_head_row - 6d"1" when direction = "00" else
                         snake_head_row + 6d"1" when direction = "01" else
                         snake_head_row;
  snake_next_head_col <= snake_head_col - 6d"1" when direction = "10" else
                         snake_head_col + 6d"1" when direction = "11" else
                         snake_head_col;
end;
