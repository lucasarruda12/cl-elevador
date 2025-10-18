library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- Up-Down Counter (udc).
entity udc is
  generic (w : natural := 5);
  port (
    clk   : in  std_logic;

    -- é melhor fazer isso e ter um vector de 2 bits
    -- ou ter um bit `ena` e um bit `e` (de entrada)
    mov   : in  std_logic_vector(1 downto 0);

    -- Eu vi umas conversas no stackexchange sobre não
    -- usar buffer (https://electronics.stackexchange.com/questions/123279/vhdl-buffer-vs-out).
    -- A outra opção seria esse q ser um out e ter um
    -- signal dentro do archtecture. Não faço ideia de qual
    -- é a diferença. A conversa no stack exchange passou
    -- voando por cima da minha cabeça.
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
  -- Esse cara é estrutural (expande pra muxeses, somadores e comparadores) 
  prox_q <= 
    -- Subindo (Se não tá no topo)
    q+1 when (mov="01" and q < (2**w - 1))
    -- Decendo (Se não tá no térreo)
    else q-1 when (mov="10" and q > 0)
    else q;

  -- Esse cara é comportamental
  process(clk)
  begin
    if (clk'event and clk='1') then
      q <= prox_q;
    end if;
  end process;
end arch;
