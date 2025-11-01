library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity intention_manager is
    port (
        clk       : in std_logic;
        reset     : in std_logic;
        call_dir  : in std_logic_vector(1 downto 0);
        intention : out std_logic_vector(1 downto 0)
    );
end intention_manager;

architecture arch of intention_manager is
    signal intention_reg : std_logic_vector(1 downto 0) := "00";
begin
    process(clk, reset)
    begin
        if reset = '1' then
            intention_reg <= "00";
        elsif rising_edge(clk) then
            case intention_reg is
                when "00" => -- Sem intenção
                    if call_dir(1) = '1' then -- Chamadas para cima
                        intention_reg <= "10";
                    elsif call_dir(0) = '1' then -- Chamadas para baixo
                        intention_reg <= "01";
                    end if;
                    
                when "10" => -- Intenção de subir
                    if call_dir(1) = '0' then -- Não há mais chamadas para cima
                        if call_dir(0) = '1' then -- Mas há para baixo
                            intention_reg <= "01";
                        else
                            intention_reg <= "00";
                        end if;
                    end if;
                    
                when "01" => -- Intenção de descer
                    if call_dir(0) = '0' then -- Não há mais chamadas para baixo
                        if call_dir(1) = '1' then -- Mas há para cima
                            intention_reg <= "10";
                        else
                            intention_reg <= "00";
                        end if;
                    end if;
                    
                when others =>
                    intention_reg <= "00";
            end case;
        end if;
    end process;
    
    intention <= intention_reg;
end arch;