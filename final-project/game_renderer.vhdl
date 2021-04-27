library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_renderer is
  port(
    row, col : in unsigned(9 downto 0);
    -- TODO: get game state
    rgb : out std_logic_vector(5 downto 0);


    a, b, c, d : in std_logic
  );
end game_renderer;

architecture synth of game_renderer is
  signal board_row, board_col : unsigned(5 downto 0);

  -- Elements to render
  signal border : std_logic := '0';
  signal debug_grid : std_logic := '0';
begin
  border <= '1' when (row >= 62 and row <= 63 and col >= 30 and col <= 609)
                  or (row >= 448 and row <= 449 and col >= 30 and col <= 609)
                  or (col >= 30 and col <= 31 and row >= 62 and row <= 449)
                  or (col >= 608 and col <= 609 and row >= 63 and row <= 449)
            else '0';
  debug_grid <= '1' when row(3 downto 0) = "0000" or col(3 downto 0) = "0000" else '0';

  board_row <= row(9 downto 4) - 4;
  board_col <= col(9 downto 4) - 2;

  -- Set pixels based on row, col, and frame count

  rgb <= "110000" when (board_row = 0 and board_col = 0 and a = '1') or (board_row = 0 and board_col = 1 and b = '1') or (board_row = 0 and board_col = 2 and c = '1') or (board_row = 0 and board_col = 3 and d = '1') else
         "111111" when border else
         "000011" when debug_grid else
         "000000";
end;
