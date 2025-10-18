library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- Up-Down Counter (udc).
entity udc is
  generic (w : natural := 5);
  port (
    clk   : in  std_logic;

    up   : in  std_logic;
    dn   : in  std_logic;

    -- Eu vi umas conversas no stackexchange sobre não
    -- usar buffer (https://electronics.stackexchange.com/questions/123279/vhdl-buffer-vs-out).
    -- A outra opção seria esse q ser um out e ter um
    -- signal dentro do archtecture. Não faço ideia de qual
    -- é a diferença. A conversa no stack exchange passou
    -- voando por cima da minha cabeça.
    q     : buffer  std_logic_vector(w-1 downto 0));
end udc;

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
  -- Esse cara é estrutural (expande pra muxeses, somadores e comparadores) 
  prox_q <= 
    q when up=dn -- 00 (que é o parado) ou 11 (que não significa nada)
    else q+1 when (up='1' and q < (2**w - 1))
    else q-1 when (dn='1' and q > 0);

  -- Esse cara é comportamental
  process(clk)
  begin
    if (clk'event and clk='1') then
      q <= prox_q;
    end if;
  end process;
end arch;
