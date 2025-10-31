library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity movement_manager is
    port (
        clk            : in std_logic;
        reset          : in std_logic;
        move_up_int    : in std_logic_vector (31 downto 0);
        move_dn_int    : in std_logic_vector (31 downto 0);
        call_dir       : in std_logic_vector(1 downto 0) := (others => '0');
        status_in      : in std_logic_vector(1 downto 0) := (others => '0');
        next_floor     : in integer range 0 to 31;
        intention_in   : in std_logic_vector(1 downto 0) := (others => '0');
        up             : out std_logic;
        dn             : out std_logic;
        intention_out  : out std_logic_vector(1 downto 0) := (others => '0'); 
        status_out     : out std_logic_vector(1 downto 0) := (others => '0')
    );
end movement_manager;

architecture arch of movement_manager is
    -- Sinais intermediários
    signal merged_up        : std_logic_vector(31 downto 0);
    signal merged_dn        : std_logic_vector(31 downto 0);
    signal reg_up         : std_logic_vector(31 downto 0);
    signal reg_dn         : std_logic_vector(31 downto 0);
    signal left_floors    : std_logic_vector(31 downto 0);
begin

    floor_index <= next_floor when next_floor >= 0 and next_floor <= 31 else
                 0 when next_floor < 0 else
                 31;

    gen_left_floors: for i in 0 to 31 generate
    left_floors(i) <= move_up_request(i) when (intention_in = "10" and status_in(1) = '0' and i < floor_index) else
                      move_up_request(i) when (intention_in = "10" and status_in = "01" and i > floor_index) else
                      move_dn_request(i) when (intention = "01" and status_in(0) = '0' and i > floor_index) else
                      move_dn_request(i) when (intention = "01" and status_in = "10" and i < floor_index) else
                      '0';
    end generate;

    intention_reg <= not intention_in when call_dir = not intention_in else
                    intention_in;


    intention_st <= "10" when call_dir(0) = '1' else
                    "01" when call_dir(1) = '1' else
                    "00";

    intention_up <= status_in(1) = '0' and left

    

            elsif intention_var = "10" then
                if status_var = "10" or status_var = "00" then 
                    left_floors := std_logic_vector(resize(unsigned(move_up_request_var(31 downto next_floor_int)), 32));
                    if left_floors /= zeros then  -- CASO ELE ESTIVER PARADO OU SUBINDO COM A INTENÇÃO DE SUBIR E AINDA HOUVEREM CHAMADAS ACIMA, ELE SOBE
                        status_int <= "10";
                        status_var := "10";
                        dn_int <= '0';
                        up_int <= '1';
                    else -- CASO ELE ESTIVER PARADO OU SUBINDO COM A INTENÇÃO DE SUBIR, HOUVEREM CHAMADAS, E ESSAS CHAMADAS NÃO ESTÃO ACIMA DO ELEVADOR, SABEMOS QUE ELAS ESTÃO ABAIXO, ELE DESCE
                        status_int <= "01";
                        status_var := "01";
                        dn_int <= '1';
                        up_int <= '0';
                    end if;
                elsif status_var = "01" then
                    left_floors := std_logic_vector(resize(unsigned(move_up_request_var(next_floor_int downto 0)), 32));
                    if left_floors /= zeros then  -- CASO ELE ESTIVER DESCENDO COM A INTENÇÃO DE SUBIR E AINDA HOUVEREM CHAMADAS ABAIXO, ELE CONTINUA DESCENDO
                        status_int <= "01";
                        status_var := "01";
                        dn_int <= '1';
                        up_int <= '0';
                    else -- CASO ELE ESTIVER DESCENDO COM A INTENÇÃO DE SUBIR, HOUVEREM CHAMADAS NO VETOR E ESSAS CHAMADAS NÃO ESTIVEREM ABAIXO, SABEMOS QUE ELAS ESTARÃO ACIMA, ENTÃO ELE COMEÇA A SUBIR
                        status_int <= "10";
                        status_var := "10";
                        dn_int <= '0';
                        up_int <= '1';
                    end if;
                end if;
            else -- NESSE CASO A INTENÇÃO SERÁ "01"
                if status_var = "01" or status_var = "00" then -- CASO ELE ESTIVER DESCENDO OU PARADO COM A INTENÇÃO DE DESCER E AINDA HOUVEREM CHAMADAS ABAIXO, ELE DESCE
                    left_floors := std_logic_vector(resize(unsigned(move_dn_request_var(next_floor_int downto 0)), 32));
                    if left_floors /= zeros then -- CASO ELE ESTIVER DESCENDO OU PARADO COM A INTENÇÃO DE DESCER E AINDA HOUVEREM CHAMADAS ABAIXO, ELE DESCE
                        status_int <= "01";
                        status_var := "01";
                        dn_int <= '1';
                        up_int <= '0';
                    else -- CASO ELE ESTIVER DESCENDO OU PARADO COM A INTENÇÃO DE DESCER, HOUVEREM CHAMADAS E ESSAS CHAMADAS NÃO ESTÃO ABAIXO, ENTÃO ELAS ESTÃO ACIMA, ELE SOBE
                        status_int <= "10";
                        status_var := "10";
                        dn_int <= '0';
                        up_int <= '1';
                    end if;
                elsif status_var = "10" then -- CASO ELE ESTIVER SUBINDO COM A INTENÇÃO DE DESCER E HOUVEREM CHAMADAS ACIMA, ELE SOBE
                    left_floors := std_logic_vector(resize(unsigned(move_dn_request_var(31 downto next_floor_int)), 32));
                    if left_floors /= zeros then
                        status_int <= "10";
                        status_var := "10";
                        dn_int <= '0';
                        up_int <= '1';
                    else -- CASO ELE ESTIVER SUBINDO COM A INTENCA?O DE DESCER, HOUVEREM CHAMADAS E ESSAS CHAMADAS NÃO ESTÃO ACIMA, SABEMOS QUE ELAS ESTÃO ABAIXO, ELE DESCE
                        status_int <= "01";
                        status_var := "01";
                        dn_int <= '1';
                        up_int <= '0';
                    end if;
                end if;
            end if;
            end if;
        end if;
    -- O SIGNAL MOVE_UP_REQUEST_INT/MOVE_DN_REQUEST_INT GUARDAM O ESTADO DO MOVE_UP_REQUEST_VAR/MOVE_DN_REQUEST_VAR DO ULTIMO CLOCK
    -- LEMBRANDO QUE AS VARS NÃO PERSISTEM ENTRE CLOCKS, POR ISSO QUE PRECISAMOS DISSO
end if;

    process(clk, reset)
    begin
        if rising_edge(reset) then
            up <= '0';
            dn <= '0';
            intention_out <= "00";
            status_out <= "00";
        elsif rising_edge(clk) then
            if call_dir = "00" then
                intention_out <= "00";
                status_out <= "00";
                dn <= '0';
                up <= '0';
            else
                
            end if;
        end if;
    end process;

end arch;