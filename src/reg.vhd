library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity reg is
  generic (w : natural := 5);
  port (
    clk   : in  std_logic;
    mov   : in  std_logic;
    ena   : in  std_logic;
    q     : buffer  std_logic_vector(w-1 downto 0));
end reg;

architecture arch of reg is
  signal prox_q : std_logic_vector(w-1 downto 0) 
    := (others => '0'); -- Quero que inicialize em 0^w
begin
  prox_q <= q when ena='0' else
            q+1 when mov='1' else
            q-1 when mov='0';

  process(clk)
  begin
    if (clk'event and clk='1') then
      q <= prox_q;
    end if;
  end process;
end arch;
