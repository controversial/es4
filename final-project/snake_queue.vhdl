library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Snake queue
-- keeps track of all positions of the snake. Each clock cycle, we add the new head to the queue and
-- move the head/tail pointers accordingly.
-- If 'expanding' is true, the head moves on each clock cycle but the tail does not.

entity snake_queue is
  port(
    mem_clk : in std_logic;
    move_clk : in std_logic;
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
  signal prev_tail_addr_q : integer := 0;
  signal head_addr_q : integer := 2;
  signal next_head_addr_q : integer := 3;
  -- row (11 downto 6) and col (5 downto 0) of tail and head
  signal prev_tail : std_logic_vector(11 downto 0);
  signal tail : std_logic_vector(11 downto 0);
--signal head : is defined like this too but it's an output port

  -- Bitmap stores every position the snake inhabits
  type BITMAP is array (integer range <>) of std_logic;
  signal snake_pos_bitmap : BITMAP(0 to 863) := (
    -- these positions correspond to the positions defined as the initial queue values
    398 => '1',
    399 => '1',
    400 => '1',
    others => '0'
  );
  signal bitmap_read_addr : integer; -- the address the user wants to access inside the bitmap
  -- Current addresses tail and “next head” within _b_itmap.
  signal tail_addr_b: integer;
  signal prev_tail_addr_b: integer;
  signal head_addr_b: integer;
  signal new_head_addr_b: integer;

  -- Signals to schedule bitmap updates to happen on the clock
  -- Bitmap updates happen one at a time: the head is added on one clock cycle, and the tail is
  -- deleted on the next. bitmap_update_addr changes to point to which we're updating right now.
  signal bitmap_update_addr : integer;
  signal which_bitmap_update : std_logic := '0';
begin
  prev_tail_addr_q <= 863 when tail_addr_q = 0 else tail_addr_q - 1;
  next_head_addr_q <= head_addr_q + 1 when head_addr_q < 863 else 0;
  -- Find addresses of tail, head, and read address within bitmap
  -- row * 36 + col
  tail_addr_b <= (to_integer(unsigned(tail(11 downto 6))) * 36) + (to_integer(unsigned(tail(5 downto 0))));
  prev_tail_addr_b <= (to_integer(unsigned(prev_tail(11 downto 6))) * 36) + (to_integer(unsigned(prev_tail(5 downto 0))));
  head_addr_b <= (to_integer(unsigned(head(11 downto 6))) * 36) + (to_integer(unsigned(head(5 downto 0))));
  new_head_addr_b <= (to_integer(unsigned(next_head(11 downto 6))) * 36) + (to_integer(unsigned(next_head(5 downto 0))));
  bitmap_read_addr <= (to_integer(unsigned(bitmap_pos(11 downto 6))) * 36) + (to_integer(unsigned(bitmap_pos(5 downto 0))));
  bitmap_update_addr <= head_addr_b when which_bitmap_update = '1' else prev_tail_addr_b;

  process(mem_clk) begin
    if rising_edge(mem_clk) then
      -- Read current coordinates of head/tail from queue
      head <= queue(head_addr_q);
      tail <= queue(tail_addr_q);
      prev_tail <= queue(prev_tail_addr_q);
      -- Output whether the snake is at the bitmap position we're interested in
      snake_here <= snake_pos_bitmap(bitmap_read_addr);

      -- Apply scheduled bitmap updates, one at a time
      snake_pos_bitmap(bitmap_update_addr) <= which_bitmap_update;
      which_bitmap_update <= not which_bitmap_update;
    end if;
  end process;

  process(move_clk) is begin
    if rising_edge(move_clk) then
      queue(next_head_addr_q) <= next_head;
      head_addr_q <= head_addr_q + 1 when head_addr_q < 863 else 0;
      -- when the snake is "expanding," the tail stays fixed and only the head moves.
      if (expanding = '0') then
        tail_addr_q <= tail_addr_q + 1 when tail_addr_q < 863 else 0;
      end if;
    end if;
  end process;
end;
