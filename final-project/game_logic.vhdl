library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_logic is
  port(
    btn_up, btn_down, btn_right, btn_left : in std_logic;
    clk : in std_logic; pixel_clock : in std_logic; game_clock : in std_logic;

    snake_head_pos : in std_logic_vector(11 downto 0);
    snake_next_head : out std_logic_vector(11 downto 0);
    bitmap_has_next_head : in std_logic;

    food_pos : out std_logic_vector(11 downto 0) := "001011" & "010010"; -- center
    expanding : out std_logic := '0';

    game_over : out std_logic := '0'
  );
end game_logic;

architecture synth of game_logic is
  type DIRECTION is (NORTH, EAST, SOUTH, WEST, NONE);
  signal snake_direction : DIRECTION := NONE;
  signal last_direction_moved : DIRECTION := NONE;
  signal button_pressed : DIRECTION := NONE;
  signal button_counter : unsigned(16 downto 0) := 17d"0";

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
      if btn_up = '1' and snake_direction /= SOUTH and last_direction_moved /= SOUTH then button_pressed <= NORTH;
      elsif btn_down = '1' and snake_direction /= NORTH and last_direction_moved /= NORTH then button_pressed <= SOUTH;
      elsif btn_left = '1' and snake_direction /= EAST and last_direction_moved /= EAST then button_pressed <= WEST;
      elsif btn_right = '1' and snake_direction /= WEST and last_direction_moved /= WEST then button_pressed <= EAST;
      else button_pressed <= NONE;
      end if;

      if button_pressed /= NONE then
        -- increment counter
        button_counter <= button_counter + 1;
        if button_counter = "11111111111111111" then
          snake_direction <= button_pressed;
        end if;
      -- Button was released
      else
        button_counter <= 17d"0";
      end if;
    end if;
  end process;

  -- Always cycling through random numbers
  process(clk) begin
    if rising_edge(clk) then
      random_pos_lfsr(0) <= random_pos_lfsr(10) xor random_pos_lfsr(9);
      random_pos_lfsr(10 downto 1) <= random_pos_lfsr(9 downto 0);
    end if;
  end process;

  -- Move snake based on its direction
  snake_next_head_row <= snake_head_row when game_over else
                         snake_head_row - 6d"1" when snake_direction = NORTH else
                         snake_head_row + 6d"1" when snake_direction = SOUTH else
                         snake_head_row;
  snake_next_head_col <= snake_head_col when game_over else
                         snake_head_col - 6d"1" when snake_direction = WEST else
                         snake_head_col + 6d"1" when snake_direction = EAST else
                         snake_head_col;

  -- Generate new food when snake eats food
  random_row <= '0' & unsigned(random_pos_lfsr(10 downto 6)) - 5d"24" when unsigned(random_pos_lfsr(10 downto 6)) >= 5d"24" else '0' & unsigned(random_pos_lfsr(10 downto 6));
  random_col <= unsigned(random_pos_lfsr(5 downto 0)) - 6d"36" when unsigned(random_pos_lfsr(5 downto 0)) >= 6d"36" else unsigned(random_pos_lfsr(5 downto 0));

  process(game_clock) begin
    if rising_edge(game_clock) then
      expanding <= '0';
      if snake_head_pos = food_pos then
        food_pos <= std_logic_vector(random_row) & std_logic_vector(random_col);
        expanding <= '1';
      end if;

      last_direction_moved <= snake_direction;
    end if;
  end process;

  -- Detect collisions with self
  process(pixel_clock) begin
    if rising_edge(pixel_clock) then
      if snake_direction /= NONE and bitmap_has_next_head = '1' then
        game_over <= '1';
      end if;

      -- If we're crashing into the walls, the game ends
      if snake_head_row >= 24 or snake_head_col >= 36 then
        game_over <= '1';
      end if;
    end if;
  end process;
end;
