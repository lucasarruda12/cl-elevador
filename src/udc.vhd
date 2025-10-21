library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- Up-Down Counter (udc).
entity udc is
  generic (w : natural := 5);
  port (
    clk : in  std_logic;
    up  : in  std_logic;
    dn  : in  std_logic;
    q   : out  std_logic_vector(w-1 downto 0));
end udc;

architecture arch of udc is
  signal q_int : std_logic_vector(w-1 downto 0) := (others => '0');
  signal prox_q : std_logic_vector(w-1 downto 0);
begin
  prox_q <= 
    q_int when up=dn 
    else q_int+1 when (up='1' and q_int < (2**w - 1))
    else q_int-1 when (dn='1' and q_int > 0);

  process(clk)
  begin
    if (clk'event and clk='1') then
      q_int <= prox_q;
      q     <= prox_q;
    end if;
  end process;
end arch;
