library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Snake queue
-- keeps track of all positions of the snake. Each clock cycle, we add the new head to the queue and
-- move the head/tail pointers accordingly.
-- If 'expanding' is true, the head moves on each clock cycle but the tail does not.

entity snake_queue is
  port(
    read_clk : in std_logic;
    update_clk : in std_logic;
    -- Output where the current head is
    head : out std_logic_vector(11 downto 0);
    -- Input information about how the snake moves
    next_head : in std_logic_vector(11 downto 0);
    expanding : in std_logic;
    -- Accessing bitmap
    bitmap_pos : in std_logic_vector(11 downto 0); -- 6-bit row, 6-bit col
    snake_here : out std_logic
  );
end snake_queue;

architecture synth of snake_queue is
  -- We need 6 bits for x pos and 6 bits for y pos for each segment of the snake
  -- The maximum possible length of the snake is 864 squares
  type COORDS_ARRAY is array (integer range <>) of std_logic_vector(11 downto 0);
  signal queue : COORDS_ARRAY(0 to 863) := (
    --    |row ||col |
    0 => "001011000010", -- initial tail: (11, 2)
    1 => "001011000011", --               (11, 3)
    2 => "001011000100", -- initial head: (11, 4)
    others => "000000000000"
  );
  -- Current addresses of head and tail within _q_ueue. These “rotate” through the queue as the snake moves.
  signal tail_addr_q : integer := 0;
  signal head_addr_q : integer := 2;
  -- row (11 downto 6) and col (5 downto 0) of tail and head
  signal tail : std_logic_vector(11 downto 0);
--signal head : is defined like this too but it's an output port

  -- Bitmap stores every position the snake inhabits
  type BITMAP_ROWS is array (integer range <>) of std_logic_vector(0 to 35);
  signal snake_pos_bitmap : BITMAP_ROWS(0 to 23) := (
    -- these positions correspond to the positions defined as the initial queue values
    -- row 11 col 2, 3, 4
    11     => "000111000000000000000000000000000000",
    others => "000000000000000000000000000000000000"
  );
  signal bitmap_read_row : integer; -- the address the user wants to access inside the bitmap
  signal bitmap_read_col : integer; -- the address the user wants to access inside the bitmap
  -- Position of tail and “next head” within bitmap.
  signal tail_bitmap_row: integer;
  signal tail_bitmap_col: integer;
  signal new_head_bitmap_row: integer;
  signal new_head_bitmap_col: integer;
begin
  -- Find addresses of tail, head, and read address within bitmap
  -- row * 36 + col
  tail_bitmap_row <= to_integer(unsigned(tail(11 downto 6)));
  tail_bitmap_col <= to_integer(unsigned(tail(5 downto 0)));
  new_head_bitmap_row <= to_integer(unsigned(next_head(11 downto 6)));
  new_head_bitmap_col <= to_integer(unsigned(next_head(5 downto 0)));
  bitmap_read_row <= to_integer(unsigned(bitmap_pos(11 downto 6)));
  bitmap_read_col <= to_integer(unsigned(bitmap_pos(5 downto 0)));

  process(read_clk) begin
    if rising_edge(update_clk) then
      -- Current coordinates of head/tail
      head <= queue(head_addr_q);
      tail <= queue(tail_addr_q);
      -- Output whether the snake is at the bitmap position we're interested in
      snake_here <= snake_pos_bitmap(bitmap_read_row)(bitmap_read_col);
    end if;
  end process;

  process(update_clk) is begin
    if rising_edge(update_clk) then
      queue(head_addr_q + 1) <= next_head;
      head_addr_q <= head_addr_q + 1 when head_addr_q <= 863 else 0;
      -- Update bitmap
      snake_pos_bitmap(new_head_bitmap_row)(new_head_bitmap_col) <= '1';
      -- when the snake is "expanding," the tail stays fixed and only the head moves.
      if (expanding = '0') then
        tail_addr_q <= tail_addr_q + 1 when tail_addr_q <= 863 else 0;
        -- Update bitmap
        snake_pos_bitmap(tail_bitmap_row)(tail_bitmap_col) <= '0';
      end if;
    end if;
  end process;
end;
