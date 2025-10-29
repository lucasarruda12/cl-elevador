library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Up-Down Counter (move_counter).
entity move_counter is
  generic (w : natural := 5);
  port (
    clk   : in std_logic;
    reset : in std_logic := '0';
    up    : in std_logic;
    dn    : in std_logic;
    q     : out integer range 0 to 31);
end move_counter;

architecture arch of move_counter is
  signal q_int: integer range 0 to 31 := 0;
  signal prox_q: integer range 0 to 31 := 0;
begin
  prox_q <= 
    q_int when up = dn 
    else q_int+1 when (up='1' and q_int < (2**w - 1))
    else q_int-1 when (dn='1' and q_int > 0)
    else q_int;

  process(clk, reset)
  begin
    if rising_edge(reset) then
      q_int <= 0;
    elsif rising_edge(clk) then
      q_int <= prox_q;
    end if;
  end process;

  q <= q_int;
  
end arch;