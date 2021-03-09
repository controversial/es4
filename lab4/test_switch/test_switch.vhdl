library IEEE;
use IEEE.std_logic_1164.all;

entity test_switch is
  port(
    gpio_2: in std_logic;
    gpio_46: in std_logic;
    gpio_47: in std_logic;
    gpio_45: in std_logic;
    gpio_3: in std_logic;
    gpio_4: in std_logic;
    gpio_44: in std_logic;
    gpio_6: in std_logic;
    led_r : out std_logic
  );
end test_switch;

architecture synth of test_switch is
begin
  -- Change this to test a different switch
  led_r <= gpio_6;
end;
