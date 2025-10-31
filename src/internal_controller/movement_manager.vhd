library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity movement_manager is
    port (
        clk            : in std_logic;
        reset          : in std_logic;
        call_dir       : in std_logic_vector(1 downto 0) := "00";
        intention      : in std_logic_vector(1 downto 0) := "00";
        at_destination : in boolean;
        move_up        : in std_logic_vector(31 downto 0) := (others => '0');
        move_dn        : in std_logic_vector(31 downto 0) := (others => '0');
        next_floor     : in integer range 0 to 31 := 0;
        status_in      : in std_logic_vector(1 downto 0) := "00";
        op             : out std_logic;
        cl             : out std_logic;
        up             : out std_logic;
        dn             : out std_logic;
        status         : out std_logic_vector(1 downto 0) := "00"
    );
end movement_manager;

architecture arch of movement_manager is
    -- Sinais intermediários
    signal left_floors : std_logic_vector(31 downto 0) := (others => '0');
    signal floor_index : integer range 0 to 31;
    signal zeros       : std_logic_vector(31 downto 0) := (others => '0');
begin

    floor_index <= next_floor when next_floor >= 0 and next_floor <= 31 else
                 0 when next_floor < 0 else
                 31;


    gen_left_floors: for i in 0 to 31 generate
    left_floors(i) <= move_up(i) when (intention = "10" and status_in(0) = '0' and i < floor_index) else
                      move_up(i) when (intention = "10" and status_in = "01" and i > floor_index) else
                      move_dn(i) when (intention = "01" and status_in(1) = '0' and i > floor_index) else
                      move_dn(i) when (intention = "01" and status_in = "10" and i < floor_index) else
                       '0';
  end generate;

    process(clk, reset)
    begin
        if rising_edge(reset) then
            op     <= '0';
            cl     <= '0';
            up     <= '0';
            dn     <= '0';
            status <= "00";
        elsif rising_edge(clk) then
            if at_destination then
                op <= '1';
                cl <= '0';
                up <= '0';
                dn <= '0';
            else 
                op <= '0';
                cl <= '1';
                if call_dir = "00" then
                    status <= "00";
                    dn <= '0';
                    up <= '0';
                else
                    if intention = "10" then
                        if status_in = "10" or status_in = "00" then 
                            if left_floors /= zeros then  -- CASO ELE ESTIVER PARADO OU SUBINDO COM A INTENÇÃO DE SUBIR E AINDA HOUVEREM CHAMADAS ACIMA, ELE SOBE
                                status <= "10";
                                dn <= '0';
                                up <= '1';
                            else -- CASO ELE ESTIVER PARADO OU SUBINDO COM A INTENÇÃO DE SUBIR, HOUVEREM CHAMADAS, E ESSAS CHAMADAS NÃO ESTÃO ACIMA DO ELEVADOR, SABEMOS QUE ELAS ESTÃO ABAIXO, ELE DESCE
                                status <= "01";
                                dn <= '1';
                                up <= '0';
                            end if;
                        elsif status_in = "01" then
                            if left_floors /= zeros then  -- CASO ELE ESTIVER DESCENDO COM A INTENÇÃO DE SUBIR E AINDA HOUVEREM CHAMADAS ABAIXO, ELE CONTINUA DESCENDO
                                status <= "01";
                                dn <= '1';
                                up <= '0';
                            else -- CASO ELE ESTIVER DESCENDO COM A INTENÇÃO DE SUBIR, HOUVEREM CHAMADAS NO VETOR E ESSAS CHAMADAS NÃO ESTIVEREM ABAIXO, SABEMOS QUE ELAS ESTARÃO ACIMA, ENTÃO ELE COMEÇA A SUBIR
                                status <= "10";
                                dn <= '0';
                                up <= '1';
                            end if;
                        end if;
                    else -- NESSE CASO A INTENÇÃO SERÁ "01"
                        if status_in = "01" or status_in = "00" then -- CASO ELE ESTIVER DESCENDO OU PARADO COM A INTENÇÃO DE DESCER E AINDA HOUVEREM CHAMADAS ABAIXO, ELE DESCE
                            if left_floors /= zeros then -- CASO ELE ESTIVER DESCENDO OU PARADO COM A INTENÇÃO DE DESCER E AINDA HOUVEREM CHAMADAS ABAIXO, ELE DESCE
                                status <= "01";
                                dn <= '1';
                                up <= '0';
                            else -- CASO ELE ESTIVER DESCENDO OU PARADO COM A INTENÇÃO DE DESCER, HOUVEREM CHAMADAS E ESSAS CHAMADAS NÃO ESTÃO ABAIXO, ENTÃO ELAS ESTÃO ACIMA, ELE SOBE
                                status <= "10";
                                dn <= '0';
                                up <= '1';
                            end if;
                        elsif status_in = "10" then -- CASO ELE ESTIVER SUBINDO COM A INTENÇÃO DE DESCER E HOUVEREM CHAMADAS ACIMA, ELE SOBE
                            if left_floors /= zeros then
                                status <= "10";
                                dn <= '0';
                                up <= '1';
                            else -- CASO ELE ESTIVER SUBINDO COM A INTENCA?O DE DESCER, HOUVEREM CHAMADAS E ESSAS CHAMADAS NÃO ESTÃO ACIMA, SABEMOS QUE ELAS ESTÃO ABAIXO, ELE DESCE
                                status <= "01";
                                dn <= '1';
                                up <= '0';
                            end if;
                        end if;
                    end if;
                    end if;
                end if;
        end if;
    end process;

end arch;
