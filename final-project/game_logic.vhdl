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
  type DIRECTION is (NORTH, EAST, SOUTH, WEST);
  signal snake_direction : DIRECTION := EAST;
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
      if btn_up = '1' and snake_direction /= SOUTH then snake_direction <= NORTH;
      elsif btn_down = '1' and snake_direction /= NORTH then snake_direction <= SOUTH;
      elsif btn_left = '1' and snake_direction /= EAST then snake_direction <= WEST;
      elsif btn_right = '1' and snake_direction /= WEST then snake_direction <= EAST;
      end if;
    end if;
  end process;

  -- Move snake based on its direction
  snake_next_head_row <= snake_head_row - 6d"1" when snake_direction = NORTH else
                         snake_head_row + 6d"1" when snake_direction = SOUTH else
                         snake_head_row;
  snake_next_head_col <= snake_head_col - 6d"1" when snake_direction = WEST else
                         snake_head_col + 6d"1" when snake_direction = EAST else
                         snake_head_col;
end;
