library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity score_calc is
  generic (w : natural := 5);
  port (
    current_floor       : in std_logic_vector(w-1 downto 0);
    current_status      : in std_logic_vector(1 downto 0);
    current_intention   : in std_logic_vector(1 downto 0);
    target_floor        : in std_logic_vector(w-1 downto 0);
    target_intention    : in std_logic_vector(1 downto 0);
    score               : out std_logic_vector(w downto 0)
  );
end score_calc;

architecture arch of score_calc is
  signal dist : std_logic_vector(w-1 downto 0);
  constant MAX_VAL : unsigned(w-1 downto 0) := (others => '1');
begin
  -- [TODO] Isso ficou tão feio...
  -- É uma forma gambiarrenta de não precisar implementar
  -- um subtrator para os std_logic_vector. Se der tempo,
  -- seria legal voltar aqui e criar vergonha na cara.
  dist <= std_logic_vector(MAX_VAL - (unsigned(current_floor) - unsigned(target_floor))) when current_floor > target_floor else
          std_logic_vector(MAX_VAL - (unsigned(target_floor) - unsigned(current_floor))) when target_floor > current_floor else
          (others => '0');

  score <= 
  -- Se está parado ou indo na mesma direção, mais prioridade
        "1" & dist when ((current_status="00") or
        (current_floor < target_floor and current_status="10" and current_intention="10" and target_intention="10") or
        (current_floor > target_floor and current_status="01" and current_intention="01" and target_intention="01")) else

  -- Se está indo pra voltar e o cara quer voltar, menos prioridade
        "0" & dist when 
        (current_floor > target_floor and current_status="01" and current_intention="10" and target_intention="10") or
        (current_floor < target_floor and current_status="10" and current_intention="01" and target_intention="01") else

  -- Se eu não vou naquela direção nem agora nem daqui a pouco,
  -- não pego a chamada
        (others => '0');
end arch;

