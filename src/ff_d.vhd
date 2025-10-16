library IEEE;
use IEEE.std_logic_1164.all;

entity ff_d is
  port (
    d   : in  BIT;
    clk : in  BIT;
    q   : out BIT
  );
end ff_d;

architecture arch of ff_d is
begin
  process(clk)
  begin
    if clk='1' then
      q <= d;
    end if;
  end process;
end arch;
