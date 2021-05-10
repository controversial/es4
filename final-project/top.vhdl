library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
  port(
    -- VGA signals
    red0, red1, grn0, grn1, blu0, blu1 : out std_logic;
    hsync, vsync : out std_logic;

    btn_up, btn_down, btn_left, btn_right : in std_logic;

    clk : in std_logic
  );
end top;

architecture synth of top is
  component vga is
    port(
      clk : in std_logic;
      rgb : in std_logic_vector(5 downto 0);
      clk_pxl : out std_logic;
      row, col : out unsigned(9 downto 0);
      blank_time : out std_logic;
      red1, red0, grn1, grn0, blu1, blu0 : out std_logic;
      hsync, vsync : out std_logic
    );
  end component;

  component game_renderer is
    port(
      row, col : in unsigned(9 downto 0);
      snake_here : in std_logic;
      rgb : out std_logic_vector(5 downto 0);
      board_row, board_col : out unsigned(5 downto 0);

      food_pos : in std_logic_vector(11 downto 0);

      game_over : in std_logic
    );
  end component;

  component game_logic is
    port(
      btn_up, btn_down, btn_right, btn_left : in std_logic;
      clk : in std_logic; pixel_clock : in std_logic;
      game_clock : in std_logic; pre_game_clock : in std_logic;

      snake_head_pos : in std_logic_vector(11 downto 0);
      snake_next_head : out std_logic_vector(11 downto 0);

      food_pos : out std_logic_vector(11 downto 0);
      expanding : out std_logic;

      bitmap_has_next_head : in std_logic;

      game_over : out std_logic
    );
  end component;

  component snake_queue is
    port(
      mem_clk: in std_logic;
      move_clk : in std_logic;
      freeze : in std_logic;
      -- Output where the current head is
      head : out std_logic_vector(11 downto 0);
      -- Input information about how the snake moves
      next_head : in std_logic_vector(11 downto 0);
      expanding : in std_logic;
      -- Accessing bitmap
      bitmap_pos : in std_logic_vector(11 downto 0); -- 6-bit row, 6-bit col
      snake_here : out std_logic
    );
  end component;

  signal pixel_clock : std_logic;
  signal row, col : unsigned(9 downto 0);
  signal display_blank_time : std_logic;
  signal rgb : std_logic_vector(5 downto 0) := "000000";

  signal counter : unsigned(20 downto 0);
  signal game_clock : std_logic;
  signal pre_game_clock : std_logic;

  -- signals for snake queue
  signal snake_head_pos : std_logic_vector(11 downto 0);
  signal snake_at_rendered_pos : std_logic;

  -- signals for game renderer
  signal rendering_board_row : unsigned(5 downto 0);
  signal rendering_board_col : unsigned(5 downto 0);
  signal rendering_pos : std_logic_vector(11 downto 0);

  signal bitmap_query_pos : std_logic_vector(11 downto 0);

  signal snake_next_head : std_logic_vector(11 downto 0);
  signal bitmap_has_next_head : std_logic;

  signal food_pos : std_logic_vector(11 downto 0);
  signal expanding : std_logic;

  signal game_over : std_logic;
begin
  vga_inst: vga port map(
    clk => clk, -- input 12M

    clk_pxl => pixel_clock, -- output clock per pixel
    row => row, col => col, -- output current block pos
    blank_time => display_blank_time,

    rgb => rgb, -- input RGB

    -- Outputs to pins of VGA breakout
    red1 => red1, red0 => red0, grn1 => grn1, grn0 => grn0, blu1 => blu1, blu0 => blu0,
    hsync => hsync, vsync => vsync
  );

  process(pixel_clock) begin
    if rising_edge(pixel_clock) then counter <= counter + 1; end if;
  end process;
  game_clock <= counter(20);
  -- up for a short time before game_clock rises
  pre_game_clock <= '1' when counter > "011111000000000000000" and counter < "100000000000000000000" else '0';

  bitmap_query_pos <= rendering_pos when not display_blank_time else snake_next_head;
  snake_queue_inst: snake_queue port map(
    mem_clk => pixel_clock,
    move_clk => game_clock,
    freeze => game_over, -- stop moving when game over
    head => snake_head_pos,
    next_head => snake_next_head,
    expanding => expanding,
    bitmap_pos => bitmap_query_pos,
    snake_here => snake_at_rendered_pos
  );
  bitmap_has_next_head <= '1' when display_blank_time and snake_at_rendered_pos else '0';

  game_renderer_inst: game_renderer port map(
    row => row,
    col => col,
    rgb => rgb,

    board_row => rendering_board_row,
    board_col => rendering_board_col,

    snake_here => snake_at_rendered_pos,

    food_pos => food_pos,

    game_over => game_over
  );
  rendering_pos <= std_logic_vector(rendering_board_row) & std_logic_vector(rendering_board_col);

  game_logic_inst : game_logic port map(
    btn_up => not btn_up, btn_down => not btn_down, btn_left => not btn_left, btn_right => not btn_right,
    clk => clk, pixel_clock => pixel_clock, game_clock => game_clock, pre_game_clock => pre_game_clock,

    snake_head_pos => snake_head_pos,
    snake_next_head => snake_next_head,
    bitmap_has_next_head => bitmap_has_next_head,

    food_pos => food_pos,

    expanding => expanding,


    game_over => game_over
  );
end;
