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
      red1, red0, grn1, grn0, blu1, blu0 : out std_logic;
      hsync, vsync : out std_logic
    );
  end component;

  component game_renderer is
    port(
      row, col : in unsigned(9 downto 0);
      snake_here : in std_logic;
      rgb : out std_logic_vector(5 downto 0);
      board_row, board_col : out unsigned(5 downto 0)
    );
  end component;

  component game_logic is
    port(
      btn_up, btn_down, btn_right, btn_left : in std_logic;
      clk : in std_logic; game_clock : in std_logic;

      snake_head_pos : in std_logic_vector(11 downto 0);
      snake_next_head : out std_logic_vector(11 downto 0)
    );
  end component;

  component snake_queue is
    port(
      read_clk: in std_logic;
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
  end component;

  signal pixel_clock : std_logic;
  signal row, col : unsigned(9 downto 0);
  signal rgb : std_logic_vector(5 downto 0) := "000000";

  signal frame_count : unsigned(3 downto 0);
  signal game_clock : std_logic;

  -- signals for snake queue
  signal snake_head_pos : std_logic_vector(11 downto 0);
  signal snake_at_rendered_pos : std_logic;

  -- signals for game renderer
  signal rendering_board_row : unsigned(5 downto 0);
  signal rendering_board_col : unsigned(5 downto 0);
  signal rendering_pos : std_logic_vector(11 downto 0);

  signal snake_next_head : std_logic_vector(11 downto 0);
begin
  vga_driver: vga port map(
    clk => clk, -- input 12M

    clk_pxl => pixel_clock, -- output clock per pixel
    row => row, col => col, -- output current block pos

    rgb => rgb, -- input RGB

    -- Outputs to pins of VGA breakout
    red1 => red1, red0 => red0, grn1 => grn1, grn0 => grn0, blu1 => blu1, blu0 => blu0,
    hsync => hsync, vsync => vsync
  );

  process(pixel_clock) begin
    -- Run once per frame: check that we're at a specific coordinate
    if rising_edge(pixel_clock) and row = 1 and col = 1 then
      frame_count <= frame_count + 1;
    end if;
  end process;
  -- Every 32 frames, we update the game
  game_clock <= '1' when frame_count = "1111" else '0';

  snake_queue_inst: snake_queue port map(
    read_clk => clk,
    update_clk => game_clock,
    head => snake_head_pos,
    next_head => snake_next_head,
    expanding => '0',
    bitmap_pos => rendering_pos,
    snake_here => snake_at_rendered_pos
  );

  game_renderer_inst: game_renderer port map(
    row => row,
    col => col,
    rgb => rgb,

    board_row => rendering_board_row,
    board_col => rendering_board_col,

    snake_here => snake_at_rendered_pos
  );
  rendering_pos <= std_logic_vector(rendering_board_row) & std_logic_vector(rendering_board_col);

  game_logic_inst : game_logic port map(
    btn_up => not btn_up, btn_down => not btn_down, btn_left => not btn_left, btn_right => not btn_right,
    clk => clk, game_clock => game_clock,

    snake_head_pos => snake_head_pos,
    snake_next_head => snake_next_head
  );
end;
