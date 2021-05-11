library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.snake_types.all;

entity game_renderer is
  port(
    row, col : in unsigned(9 downto 0);
    snake_here : in std_logic;
    rgb : out std_logic_vector(5 downto 0);
    board_row, board_col : out unsigned(5 downto 0);

    food_pos : in std_logic_vector(11 downto 0);
    snake_head_pos : in std_logic_vector(11 downto 0);
    snake_direction : in DIRECTION;

    game_score : in unsigned(9 downto 0);
    game_over : in std_logic;

    clock : in std_logic
  );
end game_renderer;

architecture synth of game_renderer is
  component number_render is
    port(
      number : in unsigned(3 downto 0); -- 0 through 9
      row : in unsigned(2 downto 0); -- 0 through 6
      col : in unsigned(2 downto 0); -- 0 through 5
      pixel : out std_logic
    );
  end component;

  component triple_digit_decoder is
    port(
      number : in unsigned(9 downto 0);
      hundreds : out unsigned(3 downto 0);
      tens : out unsigned(3 downto 0);
      ones : out unsigned(3 downto 0);

      clock : in std_logic
    );
  end component;

  -- Elements to render
  signal border : std_logic := '0';
  signal debug_grid : std_logic := '0';
  signal in_board : std_logic;
  signal food_here : std_logic;
  signal snake_head_here : std_logic;
  signal eyes_here : std_logic;

  signal board_row_raw : unsigned(5 downto 0);
  signal board_col_raw : unsigned(5 downto 0);

  -- Number rendering
  signal game_score_ones : unsigned(3 downto 0);
  signal game_score_tens : unsigned(3 downto 0);
  signal game_score_hundreds : unsigned(3 downto 0);
  signal number_pixel_on : std_logic;
  signal number_row, number_col : unsigned(9 downto 0);
  signal number_to_render : unsigned(3 downto 0);

  function dist(row_a : unsigned(3 downto 0); col_a : unsigned(3 downto 0); row_b : std_logic_vector(3 downto 0); col_b : std_logic_vector(3 downto 0)) return signed is
    variable row_a_i : signed(5 downto 0);
    variable col_a_i : signed(5 downto 0);
    variable row_b_i : signed(5 downto 0);
    variable col_b_i : signed(5 downto 0);
  begin
    row_a_i := to_signed(to_integer(unsigned(row_a)), 6); col_a_i := to_signed(to_integer(unsigned(col_a)), 6);
    row_b_i := to_signed(to_integer(unsigned(row_b)), 6); col_b_i := to_signed(to_integer(unsigned(col_b)), 6);
    return abs(row_a_i - row_b_i) + abs(col_a_i - col_b_i);
  end function;
begin
  border <= '1' when (row >= 62  and row <= 63  and col >= 30 and col <= 609)
                  or (row >= 448 and row <= 449 and col >= 30 and col <= 609)
                  or (col >= 30  and col <= 31  and row >= 62 and row <= 449)
                  or (col >= 608 and col <= 609 and row >= 63 and row <= 449)
            else '0';
  debug_grid <= '1' when row(3 downto 0) = "0000" or col(3 downto 0) = "0000" else '0';

  board_row_raw <= row(9 downto 4);
  board_col_raw <= col(9 downto 4);
  board_row <= board_row_raw - 4 when board_row_raw >= 4 and board_row_raw < 28 else 6d"24";
  board_col <= board_col_raw - 2 when board_col_raw >= 2 and board_col_raw < 38 else 6d"36";
  in_board <= '1' when board_row < 24 and board_col < 36 else '0';

  food_here <= '1' when board_row = unsigned(food_pos(11 downto 6)) and board_col = unsigned(food_pos(5 downto 0)) else '0';

  snake_head_here <= '1' when board_row = unsigned(snake_head_pos(11 downto 6)) and board_col = unsigned(snake_head_pos(5 downto 0)) else '0';
  eyes_here <= '1' when
    snake_head_here = '1' and (
      ((snake_direction = NORTH or snake_direction = SOUTH) and (
        dist(row_a => row(3 downto 0), col_a => col(3 downto 0), row_b => "1000", col_b => "0101") < 2
        or dist(row_a => row(3 downto 0), col_a => col(3 downto 0), row_b => "1000", col_b => "1011") < 2
      ))
      or
      ((snake_direction = EAST or snake_direction = WEST) and (
        dist(row_a => row(3 downto 0), col_a => col(3 downto 0), row_b => "0101", col_b => "1000") < 2
        or dist(row_a => row(3 downto 0), col_a => col(3 downto 0), row_b => "1011", col_b => "1000") < 2
      ))
    )
    else '0';


  triple_digit_decoder_inst : triple_digit_decoder port map(
    number => game_score,
    ones => game_score_ones,
    tens => game_score_tens,
    hundreds => game_score_hundreds,
    clock => clock
  );

  -- Least significant score digit: col 603–608, row 46–53
  -- Middle            score digit: col 593–598, row 46–53
  -- Most  significant score digit: col 583–588, row 46–53

  number_to_render <= game_score_hundreds when col >= 583 and col <= 588 and row >= 46 and row <= 52 else
                      game_score_tens when col >= 593 and col <= 598 and row >= 46 and row <= 52 else
                      game_score_ones when col >= 603 and col <= 608 and row >= 46 and row <= 52 else
                      4d"10"; -- renders as blank since it's outside of 0–9

  number_row <= row - 10d"46";
  number_col <= col - 10d"583" when col >= 583 and col <= 588 else
                col - 10d"593" when col >= 593 and col <= 598 else
                col - 10d"603" when col >= 603 and col <= 608 else
                col;

  number_render_inst : number_render port map(
    number => number_to_render,
    row => number_row(2 downto 0),
    col => number_col(2 downto 0),
    pixel => number_pixel_on
  );

  -- Set pixels based on row, col, and frame count

  rgb <= "111111" when number_pixel_on else
         "110000" when food_here and in_board and not debug_grid else
         "000100" when eyes_here and in_board else
         "001101" when snake_here and in_board else
         "111111" when border else
         "110000" when game_over and not in_board else
         "000001" when debug_grid else
         "000000";
end;
