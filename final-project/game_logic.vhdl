library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_logic is
  port(
    btn_up, btn_down, btn_right, btn_left : in std_logic;
    clk : in std_logic; game_clock : in std_logic;

    snake_head_pos : in std_logic_vector(11 downto 0);
    snake_next_head : out std_logic_vector(11 downto 0);

    food_pos : out std_logic_vector(11 downto 0) := "001011" & "010010"; -- center
    expanding : out std_logic := '0'
  );
end game_logic;

architecture synth of game_logic is
  type DIRECTION is (NORTH, EAST, SOUTH, WEST, NONE);
  signal snake_direction : DIRECTION := NONE;

  signal snake_head_row, snake_head_col : unsigned(5 downto 0);
  signal snake_next_head_row, snake_next_head_col : unsigned(5 downto 0) := 6d"0";

  signal random_pos_lfsr : std_logic_vector(10 downto 0) := "01110101010";
  signal random_row, random_col : unsigned(5 downto 0);
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
      elsif btn_left = '1' and snake_direction /= EAST and snake_direction /= NONE then snake_direction <= WEST;
      elsif btn_right = '1' and snake_direction /= WEST then snake_direction <= EAST;
      end if;

      random_pos_lfsr(0) <= random_pos_lfsr(10) xor random_pos_lfsr(9);
      random_pos_lfsr(10 downto 1) <= random_pos_lfsr(9 downto 0);
    end if;
  end process;

  -- Move snake based on its direction
  snake_next_head_row <= snake_head_row - 6d"1" when snake_direction = NORTH else
                         snake_head_row + 6d"1" when snake_direction = SOUTH else
                         snake_head_row;
  snake_next_head_col <= snake_head_col - 6d"1" when snake_direction = WEST else
                         snake_head_col + 6d"1" when snake_direction = EAST else
                         snake_head_col;

  -- Generate food positions
  random_row <= '0' & unsigned(random_pos_lfsr(10 downto 6)) - 5d"24" when unsigned(random_pos_lfsr(10 downto 6)) >= 5d"24" else '0' & unsigned(random_pos_lfsr(10 downto 6));
  random_col <= unsigned(random_pos_lfsr(5 downto 0)) - 6d"36" when unsigned(random_pos_lfsr(5 downto 0)) >= 6d"36" else unsigned(random_pos_lfsr(5 downto 0));

  process(game_clock) begin
    if rising_edge(game_clock) then
      expanding <= '0';
      if snake_head_pos = food_pos then
        food_pos <= std_logic_vector(random_row) & std_logic_vector(random_col);
        expanding <= '1';
      end if;
    end if;
  end process;
end;
