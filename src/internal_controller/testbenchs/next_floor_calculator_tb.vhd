library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity next_floor_calculator_tb is
end next_floor_calculator_tb;

architecture sim of next_floor_calculator_tb is

    component next_floor_calculator
        generic (w : natural := 5);
        port (
            up             : in std_logic;
            dn             : in std_logic;
            current_floor  : in std_logic_vector(w-1 downto 0);
            next_floor     : out std_logic_vector(w-1 downto 0)
        );
    end component;

    constant WIDTH : natural := 5;
    
    signal up             : std_logic := '0';
    signal dn             : std_logic := '0';
    signal current_floor  : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal next_floor     : std_logic_vector(WIDTH-1 downto 0);

begin
    UUT: next_floor_calculator
        generic map (w => WIDTH)
        port map (
            up             => up,
            dn             => dn,
            current_floor  => current_floor,
            next_floor     => next_floor
        );

    stim_proc: process
    begin
        -- Relatório de início de teste
        report "Iniciando testes..." severity note;
        
        -- Teste 1: Incrementar andar
        current_floor <= "00010"; -- Andar 2
        up <= '1';
        dn <= '0';
        wait for 10 ns;
        assert next_floor = "00011" 
            report "Teste 1 falhou: Esperado=3, Obtido=" & integer'image(to_integer(unsigned(next_floor)))
            severity error;
        
        -- Teste 2: Decrementar andar
        current_floor <= "00100"; -- Andar 4
        up <= '0';
        dn <= '1';
        wait for 10 ns;
        assert next_floor = "00011" 
            report "Teste 2 falhou: Esperado=3, Obtido=" & integer'image(to_integer(unsigned(next_floor)))
            severity error;
        
        -- Teste 3: Manter andar (nenhum botão pressionado)
        current_floor <= "00101"; -- Andar 5
        up <= '0';
        dn <= '0';
        wait for 10 ns;
        assert next_floor = "00101" 
            report "Teste 3 falhou: Esperado=5, Obtido=" & integer'image(to_integer(unsigned(next_floor)))
            severity error;
        
        report "Todos os testes concluídos!" severity note;
        wait;
    end process;

end sim;