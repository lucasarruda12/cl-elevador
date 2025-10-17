library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- Up-Down Counter (udc).
entity udc is
  generic (w : natural := 5);
  port (
    clk   : in  std_logic;
    mov   : in  std_logic_vector(1 downto 0);
    q     : buffer  std_logic_vector(w-1 downto 0));
end reg;

-- TODO: Deletar esses comentários.
-- Eu não sei se eu entendi legal como que o professor
-- quer que a gente lide com comportamental vs estrutural.
-- Todos os slides de VHDL dos coisas sequenciais são bem
-- comportamentais. Tentei deixar o mais meio termo possível,
-- mas talvez tenha ido longe demais.
architecture arch of udc is
  signal prox_q : std_logic_vector(w-1 downto 0) 
    := (others => '0'); -- Quero que inicialize em 0^w
begin
  prox_q <= -- Esse cara é estrutural (expande pra muxeses) 
           -- Parado
            q when mov="00"
           -- Subindo (Se não tá no topo)
            else q+1 when (mov="01" and q < (2**w - 1))
           -- Decendo (Se não tá no primeiro)
            else q-1 when (mov="10" and q > 0);

  process(clk) -- Esse cara é comportamental
  begin
    if (clk'event and clk='1') then
      q <= prox_q;
    end if;
  end process;
end arch;
