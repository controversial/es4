library IEEE;
use IEEE.std_logic_1164.all;

entity test_switch is
  port(
    -- DP switches 1–8
    gpio_2: in std_logic;
    gpio_46: in std_logic;
    gpio_47: in std_logic;
    gpio_45: in std_logic;
    gpio_3: in std_logic;
    gpio_4: in std_logic;
    gpio_44: in std_logic;
    gpio_6: in std_logic;
    -- Push button switches
    gpio_28: in std_logic;
    gpio_38: in std_logic;
    -- Indicator LEDs
    led_r : out std_logic;
    led_g : out std_logic;
    led_b : out std_logic
  );
end test_switch;

architecture synth of test_switch is
begin
  led_g <= gpio_28;
  led_b <= gpio_38;
  -- Change this to test a different DP switch
  led_r <= gpio_6;
end;
