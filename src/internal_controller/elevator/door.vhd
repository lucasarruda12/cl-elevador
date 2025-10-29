library IEEE;
use IEEE.std_logic_1164.all;

entity door is
  port (
    clk   : std_logic;
    reset : std_logic := '0';
    op    : std_logic;
    cl    : std_logic;
    q     : out std_logic := '0');
end door;

architecture arch of door is
  signal prox_q : std_logic;   
  signal q_int  : std_logic := '0';
begin
  prox_q <= 
    q_int when op=cl
    else '0' when (cl='1')
    else '1' when (op='1');

  process(clk, reset)
  begin
    if rising_edge(reset) then
      q <= '0';
    elsif rising_edge(clk) then
      q <= prox_q;
    end if;
  end process;
end arch;

