library IEEE;
use IEEE.std_logic_1164.all;

package custom_types is

-- As coisas com tipo call ficaram internas dentro da implementação do 
-- controlador externo. Se você vir uma coisa do tipo call_vector e outra
-- do tipo std_logic_vector uma do lado da outra aparentemente sem motivo,
-- é porque uma vai/vem pro/do lado de fora (controlador interno, botões, etc...)
-- e a outra vai/vem pro/do lado de dentro (de volta pro controlador externo).
-- um exemplo bom disso é o call_dispatcher.
  
  type call is record
    active     : std_logic;
    score      : std_logic_vector(5 downto 0);
    respondent : std_logic_vector(1 downto 0);
  end record;

  type call_vector is array (natural range <>) of call;

end package;
