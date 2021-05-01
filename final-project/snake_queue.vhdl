library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Snake queue
-- keeps track of all positions of the snake. Each clock cycle, we add the new head to the queue and
-- move the head/tail pointers accordingly.
-- If 'expanding' is true, the head moves on each clock cycle but the tail does not.

entity snake_queue is
  port(
    clk : in std_logic;
    -- Output where the current head is
    head : out std_logic_vector(11 downto 0);
    -- Input information about how the snake moves
    next_head : in std_logic_vector(11 downto 0);
    expanding : in std_logic;
    -- Accessing bitmap
    addr : integer; -- 6-bit row, 6-bit col
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
  -- Current addresses tail and “next head” within _b_itmap.
  signal tail_addr_b: integer;
  signal n_head_addr_b: integer;

  -- Bitmap stores every position the snake inhabits
  type BITMAP is array (integer range <>) of std_logic;
  signal snake_pos_bitmap : BITMAP(0 to 863) := (
    -- these positions correspond to the positions defined as the initial queue values
    398 => '1',
    399 => '1',
    400 => '1',
    others => '0'
  );
begin
  -- Current coordinates of head
  head <= queue(head_addr_q);
  tail <= queue(tail_addr_q);
  -- Output the position
  snake_here <= snake_pos_bitmap(addr);

  -- Find addresses of tail and head within bitmap
  -- row * 36 + col
  tail_addr_b <= (to_integer(unsigned(tail(11 downto 6))) * 36) + (to_integer(unsigned(tail(5 downto 0))));
  n_head_addr_b <= (to_integer(unsigned(next_head(11 downto 6))) * 36) + (to_integer(unsigned(next_head(5 downto 0))));

  process(clk) is begin
    if (rising_edge(clk)) then
      queue(head_addr_q + 1) <= next_head;
      head_addr_q <= head_addr_q + 1 when head_addr_q <= 863 else 0;
      -- Update bitmap
      snake_pos_bitmap(n_head_addr_b) <= '1';
      -- when the snake is "expanding," the tail stays fixed and only the head moves.
      if (expanding = '0') then
        tail_addr_q <= tail_addr_q + 1 when tail_addr_q <= 863 else 0;
        -- Update bitmap
        snake_pos_bitmap(tail_addr_b) <= '0';
      end if;
    end if;

    -- update bitmap to hold every snake position
  end process;
end;
