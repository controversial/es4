library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_renderer is
  port(
    row, col : in unsigned(9 downto 0);
    frame_count : in unsigned(17 downto 0);

    rgb : out std_logic_vector(5 downto 0)
  );
end game_renderer;

architecture synth of game_renderer is
  signal border : std_logic := '0';
  signal debug_grid : std_logic := '0';
begin
  border <= '1' when (row >= 63 and row <= 64 and col >= 32 and col <= 609)
                  or (row >= 448 and row <= 449 and col >= 32 and col <= 609)
                  or (col >= 31 and col <= 32 and row >= 63 and row <= 449)
                  or (col >= 608 and col <= 609 and row >= 63 and row <= 449)
            else '0';
  debug_grid <= '1' when row(3 downto 0) = "0000" or col(3 downto 0) = "0000" else '0';
  -- Set pixels based on row, col, and frame count

  rgb <= "111111" when border else
         "000011" when debug_grid else
         "000000";
end;
