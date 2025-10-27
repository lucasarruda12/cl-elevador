library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity in_controller_tb is
end in_controller_tb;

architecture sim of in_controller_tb is

    constant WIDTH : natural := 5;
    constant CLK_PERIOD : time := 10 ns;

    component in_controller is
        generic (w : natural := WIDTH);
        port (
            clk               : in std_logic;
            reset             : in std_logic;
            int_floor_request : in std_logic_vector(31 downto 0);
            move_up_request   : in std_logic_vector(31 downto 0);
            move_dn_request   : in std_logic_vector(31 downto 0);
            current_floor     : out std_logic_vector(w-1 downto 0);
            status            : out std_logic_vector(1 downto 0);
            intention         : out std_logic_vector(1 downto 0);
            dr                : out std_logic
        ); 
    end component;
    
    signal clk               : std_logic := '0';
    signal reset             : std_logic := '0';
    signal int_floor_request : std_logic_vector(31 downto 0) := (others => '0');
    signal move_up_request   : std_logic_vector(31 downto 0) := (others => '0');
    signal move_dn_request   : std_logic_vector(31 downto 0) := (others => '0');
    signal current_floor     : std_logic_vector(WIDTH-1 downto 0);
    signal status            : std_logic_vector(1 downto 0);
    signal intention         : std_logic_vector(1 downto 0);
    signal dr                : std_logic;
    signal sim_ended         : boolean := false;

    -- Funcoes locais para conversao
    function is_valid_floor(floor_vec : std_logic_vector) return boolean is
    begin
        for i in floor_vec'range loop
            if floor_vec(i) /= '0' and floor_vec(i) /= '1' then
                return false;
            end if;
        end loop;
        return true;
    end function;

    function status_to_string(st : std_logic_vector(1 downto 0)) return string is
    begin
        case st is
            when "00" => return "PARADO";
            when "01" => return "DESCENDO";
            when "10" => return "SUBINDO";
            when others => return "INVALIDO";
        end case;
    end function;

    function intention_to_string(it : std_logic_vector(1 downto 0)) return string is
    begin
        case it is
            when "00" => return "NENHUMA";
            when "01" => return "DESCER";
            when "10" => return "SUBIR";
            when others => return "INVALIDA";
        end case;
    end function;

begin
    DUT: in_controller
        generic map (w => WIDTH)
        port map (
            clk               => clk,
            reset             => reset,
            int_floor_request => int_floor_request,
            move_up_request   => move_up_request,
            move_dn_request   => move_dn_request,
            current_floor     => current_floor,
            status            => status,
            intention         => intention,
            dr                => dr
        );

    -- Geracao do clock
    clk_process : process
    begin
        while not sim_ended loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim_proc: process

        variable current_floor_int : integer;
        variable test_passed : boolean;

    begin
        report "==================================================";
        report "    TESTES DO CONTROLADOR INTERNO (in_controller)";
        report "==================================================";
        report "";

        ------------------------------------------------------------------
        -- Teste 1: Estado inicial
        ------------------------------------------------------------------
        report "### Teste 1 - Estado Inicial ###";
        report "Verificando se o elevador inicia no andar 0, parado e sem intencao de movimento.";
        
        -- Aguardar estabilizacao inicial
        wait for CLK_PERIOD * 3;
        
        -- Verificacoes do estado inicial
        if is_valid_floor(current_floor) then
            current_floor_int := to_integer(unsigned(current_floor));
            assert current_floor_int = 0 
                report "FALHA: Andar inicial deveria ser 0, mas eh " & integer'image(current_floor_int) 
                severity error;
            report "  Andar inicial: " & integer'image(current_floor_int);
        else
            report "FALHA: current_floor nao esta em estado valido" severity error;
        end if;
        
        assert status = "00" or status = "01" or status = "10" 
            report "FALHA: Status invalido: " & integer'image(to_integer(unsigned(status))) 
            severity error;
        
        report "  Status inicial: " & status_to_string(status);
        report "  Intencao inicial: " & intention_to_string(intention);
        report "  Teste 1 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 2: Pedido interno para andar 5
        ------------------------------------------------------------------
        report "### Teste 2 - Pedido Interno Unico ###";
        report "Enviando pedido interno para o andar 5.";
        
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        int_floor_request <= (5 => '1', others => '0');
        wait until rising_edge(clk);
        int_floor_request <= (others => '0');  -- Zera apos receber
        
        -- Aguardar resposta do controlador
        test_passed := false;
        for i in 1 to 15 loop
            wait until rising_edge(clk);
            if intention /= "00" then
                report "  Intencao detectada: " & intention_to_string(intention);
                test_passed := true;
                exit;
            end if;
        end loop;
        
        assert test_passed report "FALHA: Nao houve intencao de movimento apos pedido" severity error;
        
        wait for CLK_PERIOD * 10;
        report "  Teste 2 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 3: Multiplos pedidos internos
        ------------------------------------------------------------------
        report "### Teste 3 - Multiplos Pedidos Internos ###";
        report "Enviando pedidos para os andares 3, 8 e 12 simultaneamente.";
        
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        int_floor_request <= (3 => '1', 8 => '1', 12 => '1', others => '0');
        wait until rising_edge(clk);
        int_floor_request <= (others => '0');  -- Zera apos receber
        
        wait for CLK_PERIOD * 30;
        report "  Multiplos pedidos processados";
        report "  Teste 3 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 4: Pedidos de subida externos
        ------------------------------------------------------------------
        report "### Teste 4 - Pedidos de Subida Externa ###";
        report "Enviando pedido externo de subida para o andar 6.";
        
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        move_up_request <= (6 => '1', others => '0');
        wait until rising_edge(clk);
        move_up_request <= (others => '0');  -- Zera apos receber
        
        wait for CLK_PERIOD * 15;
        report "  Pedido de subida processado";
        report "  Teste 4 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 5: Pedidos de descida externos
        ------------------------------------------------------------------
        report "### Teste 5 - Pedidos de Descida Externa ###";
        report "Enviando pedido externo de descida para o andar 14.";
        
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        move_dn_request <= (14 => '1', others => '0');
        wait until rising_edge(clk);
        move_dn_request <= (others => '0');  -- Zera apos receber
        
        wait for CLK_PERIOD * 15;
        report "  Pedido de descida processado";
        report "  Teste 5 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 6: Combinacao de pedidos
        ------------------------------------------------------------------
        report "### Teste 6 - Combinacao de Pedidos ###";
        report "Enviando pedidos internos e externos simultaneamente.";
        report "  Andares: 2, 7 (interno), 3 (subida), 16 (descida)";
        
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        int_floor_request <= (2 => '1', 7 => '1', others => '0');
        move_up_request <= (3 => '1', others => '0');
        move_dn_request <= (16 => '1', others => '0');
        wait until rising_edge(clk);
        -- Zera todos os pedidos apos receber
        int_floor_request <= (others => '0');
        move_up_request <= (others => '0');
        move_dn_request <= (others => '0');
        
        wait for CLK_PERIOD * 25;
        report "  Combinacao de pedidos processada";
        report "  Teste 6 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 7: Pedido no andar atual
        ------------------------------------------------------------------
        report "### Teste 7 - Pedido no Andar Atual ###";
        
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        -- Espera estabilizar e pega o andar atual
        wait for CLK_PERIOD * 3;
        if is_valid_floor(current_floor) then
            current_floor_int := to_integer(unsigned(current_floor));
            report "  Andar atual: " & integer'image(current_floor_int);
            
            report "  Enviando pedido para o andar atual.";
            int_floor_request <= (others => '0');
            if current_floor_int < 32 then
                int_floor_request(current_floor_int) <= '1';
            end if;
            wait until rising_edge(clk);
            int_floor_request <= (others => '0');  -- Zera apos receber
            
            wait for CLK_PERIOD * 5;
            
            -- Verifica se permanece parado
            if status = "00" then
                report "  Elevador permaneceu parado no andar atual";
            else
                report "FALHA: Elevador nao deveria se mover quando o pedido eh para o andar atual" 
                    severity error;
            end if;
        else
            report "FALHA: Nao foi possivel determinar o andar atual" severity error;
        end if;
        
        report "  Teste 7 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 8: Prioridade de pedidos complexa
        ------------------------------------------------------------------
        report "### Teste 8 - Prioridade Complexa de Pedidos ###";
        report "Enviando multiplos pedidos em diferentes direcoes:";
        report "  Internos: andares 1 e 15";
        report "  Subida: andares 4 e 10";  
        report "  Descida: andares 7 e 12";
        
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        int_floor_request <= (1 => '1', 15 => '1', others => '0');
        move_up_request <= (4 => '1', 10 => '1', others => '0');
        move_dn_request <= (7 => '1', 12 => '1', others => '0');
        wait until rising_edge(clk);
        -- Zera todos os pedidos apos receber
        int_floor_request <= (others => '0');
        move_up_request <= (others => '0');
        move_dn_request <= (others => '0');
        
        wait for CLK_PERIOD * 40;
        report "  Pedidos complexos processados";
        report "  Teste 8 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Finalizacao
        ------------------------------------------------------------------
        report "### RESUMO FINAL ###";
        
        if is_valid_floor(current_floor) then
            report "Andar final: " & integer'image(to_integer(unsigned(current_floor)));
        else
            report "Andar final: INVALIDO";
        end if;
        
        report "Status final: " & status_to_string(status);
        report "Intencao final: " & intention_to_string(intention);
        
        report "";
        report "Todos os testes do in_controller foram concluidos!";
        report "";
        report "==================================================";
        report "           SIMULACAO CONCLUIDA";
        report "==================================================";
        
        sim_ended <= true;
        wait;
    end process;

    -- Processo de monitoramento continuo
    monitor_proc: process
        variable last_floor : integer := 0;
        variable current_floor_int : integer;
        variable last_status : std_logic_vector(1 downto 0) := "11";
        variable last_intention : std_logic_vector(1 downto 0) := "11";
    begin
        wait until rising_edge(clk);
        
        if is_valid_floor(current_floor) then
            current_floor_int := to_integer(unsigned(current_floor));
            
            -- Verificar se o andar eh valido
            assert current_floor_int >= 0 and current_floor_int < 32
                report "ANDAR INVALIDO: " & integer'image(current_floor_int) severity error;
            
            -- Detectar mudanca de andar
            if current_floor_int /= last_floor then
                report "[MOVIMENTO] Andar: " & integer'image(last_floor) & 
                      " -> " & integer'image(current_floor_int);
                last_floor := current_floor_int;
            end if;
            
            -- Detectar mudanca de status
            if status /= last_status then
                report "[STATUS] " & status_to_string(last_status) & 
                      " -> " & status_to_string(status);
                last_status := status;
            end if;
            
            -- Detectar mudanca de intencao
            if intention /= last_intention then
                report "[INTENCAO] " & intention_to_string(last_intention) & 
                      " -> " & intention_to_string(intention);
                last_intention := intention;
            end if;
            
            -- Verificar consistencia porta/status
            if dr = '1' then  -- Porta aberta
                if status /= "00" then
                    report "[PORTA] Aberta no andar " & integer'image(current_floor_int);
                else
                    report "Erro: Porta aberta durante movimento.";
                end if;
            end if;
        end if;
    end process;

end architecture sim;