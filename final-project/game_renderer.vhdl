library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_renderer is
  port(
    row, col : in unsigned(9 downto 0);
    snake_here : in std_logic;
    rgb : out std_logic_vector(5 downto 0);
    board_row, board_col : out unsigned(5 downto 0)
  );
end game_renderer;

architecture synth of game_renderer is

  -- Elements to render
  signal border : std_logic := '0';
  signal debug_grid : std_logic := '0';
  signal in_board : std_logic;
begin
  border <= '1' when (row >= 62 and row <= 63 and col >= 30 and col <= 609)
                  or (row >= 448 and row <= 449 and col >= 30 and col <= 609)
                  or (col >= 30 and col <= 31 and row >= 62 and row <= 449)
                  or (col >= 608 and col <= 609 and row >= 63 and row <= 449)
            else '0';
  debug_grid <= '1' when row(3 downto 0) = "0000" or col(3 downto 0) = "0000" else '0';

  board_row <= row(9 downto 4) - 4;
  board_col <= col(9 downto 4) - 2;
  in_board <= '1' when board_row < 24 and board_col < 36 else '0';

  -- Set pixels based on row, col, and frame count

  rgb <= "111111" when border else
         "110000" when snake_here and in_board else
         "000001" when debug_grid else
         "000000";
end;
