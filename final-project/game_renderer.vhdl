library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_renderer is
  port(
    row, col : in unsigned(9 downto 0);
    snake_here : in std_logic;
    rgb : out std_logic_vector(5 downto 0);
    board_row, board_col : out unsigned(5 downto 0);

    food_pos : in std_logic_vector(11 downto 0);

    game_over : in std_logic
  );
end game_renderer;

architecture synth of game_renderer is

  -- Elements to render
  signal border : std_logic := '0';
  signal debug_grid : std_logic := '0';
  signal in_board : std_logic;
  signal food_here : std_logic;

  signal board_row_raw : unsigned(5 downto 0);
  signal board_col_raw : unsigned(5 downto 0);
begin
  border <= '1' when (row >= 62 and row <= 63 and col >= 30 and col <= 609)
                  or (row >= 448 and row <= 449 and col >= 30 and col <= 609)
                  or (col >= 30 and col <= 31 and row >= 62 and row <= 449)
                  or (col >= 608 and col <= 609 and row >= 63 and row <= 449)
            else '0';
  debug_grid <= '1' when row(3 downto 0) = "0000" or col(3 downto 0) = "0000" else '0';

  board_row_raw <= row(9 downto 4);
  board_col_raw <= col(9 downto 4);
  board_row <= board_row_raw - 4 when board_row_raw >= 4 and board_row_raw < 28 else 6d"24";
  board_col <= board_col_raw - 2 when board_col_raw >= 2 and board_col_raw < 38 else 6d"36";
  in_board <= '1' when board_row < 24 and board_col < 36 else '0';

  food_here <= '1' when board_row = unsigned(food_pos(11 downto 6)) and board_col = unsigned(food_pos(5 downto 0)) else '0';

  -- Set pixels based on row, col, and frame count

  rgb <= "110000" when game_over and in_board else
         "001101" when snake_here and in_board else
         "110000" when food_here and in_board and not debug_grid else
         "111111" when border else
         "000001" when debug_grid else
         "000000";
end;
