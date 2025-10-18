library IEEE;
use IEEE.std_logic_1164.all;

entity door is
  port (
    clk : std_logic;
    op : std_logic;
    cl : std_logic;
    q   : buffer std_logic);
end door;

architecture arch of door is
  signal prox_q : std_logic;   
begin
  prox_q <= 
    q when op=cl
    else '0' when (cl='1')
    else '1' when (op='1');

  process(clk)
  begin
    if (clk'event and clk='1') then
      q <= prox_q;
    end if;
  end process;
end arch;

