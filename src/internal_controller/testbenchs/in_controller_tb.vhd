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

    -- Sinais para verificacao de movimento com porta aberta
    signal door_open_floor   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal door_was_open     : boolean := false;
    signal door_open_time    : time := 0 ns;

    -- Funcões locais para conversao
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

    -- Processo para verificacao de movimento com porta aberta
    door_monitor: process(clk)
        variable last_dr : std_logic := '0';
        variable saved_floor : std_logic_vector(WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            -- Detectar transicao de porta fechada para aberta
            if last_dr = '0' and dr = '1' then
                saved_floor := current_floor;
                door_open_floor <= current_floor;
                door_was_open <= true;
                door_open_time <= now;
                report "[PORTA] Abriu no andar " & integer'image(to_integer(unsigned(current_floor)));
            end if;
            
            -- Detectar transicao de porta aberta para fechada
            if last_dr = '1' and dr = '0' then
                if door_was_open then
                    if saved_floor /= current_floor then
                        report "ERRO GRAVE: Elevador se moveu com porta aberta! Andar inicial: " & 
                               integer'image(to_integer(unsigned(saved_floor))) & 
                               ", Andar final: " & integer'image(to_integer(unsigned(current_floor))) &
                               " Tempo porta aberta: " & time'image(now - door_open_time)
                               severity error;
                    else
                        report "[PORTA] Fechou no mesmo andar: " & integer'image(to_integer(unsigned(current_floor)));
                    end if;
                    door_was_open <= false;
                end if;
            end if;
            
            last_dr := dr;
        end if;
    end process;

    stim_proc: process

        procedure apply_reset is
        begin
            reset <= '1';
            int_floor_request <= (others => '0');
            move_up_request <= (others => '0');
            move_dn_request <= (others => '0');
            wait for CLK_PERIOD * 2;
            reset <= '0';
            wait for CLK_PERIOD * 2;
        end procedure;

        procedure send_requests(
            int_floors : in std_logic_vector(31 downto 0);
            up_floors  : in std_logic_vector(31 downto 0);
            down_floors: in std_logic_vector(31 downto 0);
            duration   : in natural := 20
        ) is
        begin
            int_floor_request <= int_floors;
            move_up_request <= up_floors;
            move_dn_request <= down_floors;
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            int_floor_request <= (others => '0');
            move_up_request <= (others => '0');
            move_dn_request <= (others => '0');
            wait for CLK_PERIOD * duration;
        end procedure;

    begin
        report "==================================================";
        report "    TESTES DO CONTROLADOR INTERNO (in_controller)";
        report "==================================================";
        report "";

        ------------------------------------------------------------------
        -- Teste 1: Estado inicial e pedidos internos basicos
        ------------------------------------------------------------------
        report "### Teste 1 - Estado Inicial e Pedidos Internos ###";
        apply_reset;
        
        -- Verificar estado inicial
        assert to_integer(unsigned(current_floor)) = 0 
            report "FALHA: Andar inicial deveria ser 0" severity error;
        report "  Andar inicial: " & integer'image(to_integer(unsigned(current_floor)));


        report "Pedidos interno no andar 5";
        -- Pedido interno simples
        send_requests(
            int_floors => (5 => '1', others => '0'),
            up_floors => (others => '0'),
            down_floors => (others => '0'),
            duration => 20
        );
        report "  Teste 1 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 2: Dois pedidos para subir
        ------------------------------------------------------------------
        report "### Teste 2 - Dois Pedidos para Subir ###";
        report "Pedidos de subida nos andares 4 e 8";
        
        apply_reset;
        send_requests(
            int_floors => (others => '0'),
            up_floors => (4 => '1', 8 => '1', others => '0'),
            down_floors => (others => '0'),
            duration => 25
        );
        report "  Teste 2 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 3: Dois pedidos para descer
        ------------------------------------------------------------------
        report "### Teste 3 - Dois Pedidos para Descer ###";
        report "Pedidos de descida nos andares 12 e 16";
        
        apply_reset;
        send_requests(
            int_floors => (others => '0'),
            up_floors => (others => '0'),
            down_floors => (12 => '1', 16 => '1', others => '0'),
            duration => 30
        );
        report "  Teste 3 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 4: Pedido para Subir em Andar Superior e Descer em Andar Inferior 
        ------------------------------------------------------------------
        report "### Teste 4 - Pedido para Subir em Andar Superior e Descer em Andar Inferior ###";
        report "Subir no andar 6, Descer no andar 3";
        
        apply_reset;
        send_requests(
            int_floors => (others => '0'),
            up_floors => (6 => '1', others => '0'),
            down_floors => (3 => '1', others => '0'),
            duration => 30
        );
        report "  Teste 4 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 5: Pedido para Subir em Andar Inferior e Descer em andar Superior
        ------------------------------------------------------------------
        report "### Teste 5 - Pedido para Subir em Andar Inferior e Descer em andar Superior ###";
        report "Descer no 10, Subir no 5";
        
        apply_reset;
        -- Pedidos: descer no 10, subir no 15
        send_requests(
            int_floors => (others => '0'),
            up_floors => (5 => '1', others => '0'),
            down_floors => (10 => '1', others => '0'),
            duration => 30
        );
        report "  Teste 5 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 6: Subir e Descer no mesmo andar
        ------------------------------------------------------------------
        report "### Teste 6 - Subir e Descer no Mesmo Andar ###";
        report "Subir e Descer no andar 8 simultaneamente";
        
        apply_reset;
        send_requests(
            int_floors => (others => '0'),
            up_floors => (8 => '1', others => '0'),
            down_floors => (8 => '1', others => '0'),
            duration => 20
        );
        report "  Teste 6 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 7: Dois para subir e um para descer no menor andar de subida
        ------------------------------------------------------------------
        report "### Teste 7 - Dois Subir + Descer no Menor Andar de Subida ###";
        report "Subir nos andares 5 e 9, Descer no 5";
        
        apply_reset;
        send_requests(
            int_floors => (others => '0'),
            up_floors => (5 => '1', 9 => '1', others => '0'),
            down_floors => (5 => '1', others => '0'),
            duration => 35
        );
        report "  Teste 7 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 8: Dois para descer e um para subir no maior andar de descida
        ------------------------------------------------------------------
        report "### Teste 8 - Dois Descer + Subir no Maior Andar de Descida ###";
        report "Descer nos andares 14 e 18, Subir no 14";
        
        apply_reset;
        send_requests(
            int_floors => (others => '0'),
            up_floors => (14 => '1', others => '0'),
            down_floors => (14 => '1', 18 => '1', others => '0'),
            duration => 40
        );
        report "  Teste 8 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 10: Pedido subsequente durante movimento
        ------------------------------------------------------------------
        report "### Teste 9 - Pedido Subsequente Durante Movimento ###";
        report "Subir nos andares 2 e 10, depois pedido interno para descer";
        
        apply_reset;
        -- Envia pedidos iniciais de subida
        send_requests(
            int_floors => (others => '0'),
            up_floors => (2 => '1', 10 => '1', others => '0'),
            down_floors => (others => '0'),
            duration => 5
        );
        
        report "  Enviando pedido interno para descer após 4 clocks";
        int_floor_request <= (7 => '1', others => '0');
        wait until rising_edge(clk);
        int_floor_request <= (others => '0');
        
        wait for CLK_PERIOD * 30;
        report "  Teste 9 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 10: Caso complexo de prioridades
        ------------------------------------------------------------------
        report "### Teste 10 - Caso Complexo de Prioridades ###";
        report "Multiplos pedidos internos e externos misturados";
        
        apply_reset;
        send_requests(
            int_floors => (4 => '1', 11 => '1', 17 => '1', others => '0'),
            up_floors => (6 => '1', 13 => '1', others => '0'),
            down_floors => (8 => '1', 15 => '1', others => '0'),
            duration => 50
        );
        report "  Teste 10 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 10: Caso complexo de prioridades
        ------------------------------------------------------------------
        report "### Teste 11 - Pedido no andar atual ###";
        report "Pedido para subir no andar 0";
        
        apply_reset;
        send_requests(
            int_floors => (others => '0'),
            up_floors => (0 => '1', others => '0'),
            down_floors => (others => '0'),
            duration => 50
        );
        report "  Teste 10 concluido com sucesso";
        report "";
        
        ------------------------------------------------------------------
        -- Finalizacao
        ------------------------------------------------------------------
        report "### RESUMO FINAL ###";
        report "Andar final: " & integer'image(to_integer(unsigned(current_floor)));
        report "Status final: " & status_to_string(status);
        report "Intencao final: " & intention_to_string(intention);
        
        report "";
        report "Todos os testes do in_controller foram concluidos!";
        report "==================================================";
        report "           SIMULACAO CONCLUÍDA";
        report "==================================================";
        
        sim_ended <= true;
        wait;
    end process;

    -- Processo de monitoramento continuo
    monitor_proc: process
        variable last_floor : integer := -1;
        variable current_floor_int : integer;
        variable last_status : std_logic_vector(1 downto 0) := "11";
        variable last_intention : std_logic_vector(1 downto 0) := "11";
    begin
        wait until rising_edge(clk);
        
        current_floor_int := to_integer(unsigned(current_floor));
        
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
    end process;

end architecture sim;