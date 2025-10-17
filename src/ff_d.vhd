library IEEE;
use IEEE.std_logic_1164.all;

entity ff_d is
  port (
    d     : in  BIT;
    clk   : in  BIT;
    clrn  : in  BIT;
    ena   : in  BIT;
    q     : out BIT
  );
end ff_d;

architecture arch of ff_d is
begin
  process(clk, clrn)
  begin
    if clrn='0' then
      q <= '0';
    elsif (clk'event and clk='1') then
      if ena='1' then
        q <= d;
      end if;
    end if;
  end process;
end arch;
