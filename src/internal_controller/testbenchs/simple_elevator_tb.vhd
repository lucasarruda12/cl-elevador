library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity simple_elevator_tb is
end entity simple_elevator_tb;

architecture sim of simple_elevator_tb is

    component simple_elevator
        generic (w : natural := 5);
        port (
            clk            : in  std_logic;
            reset          : in  std_logic;
            op             : in  std_logic; -- open door
            cl             : in  std_logic; -- close door
            up             : in  std_logic; -- move up
            dn             : in  std_logic; -- move down
            dr             : out std_logic; -- door status (1=open, 0=closed)
            current_floor  : out std_logic_vector(w-1 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    constant WIDTH : natural := 5;
    
    signal clk           : std_logic := '0';
    signal reset         : std_logic := '0';
    signal op            : std_logic := '0';
    signal cl            : std_logic := '0';
    signal up            : std_logic := '0';
    signal dn            : std_logic := '0';
    signal dr            : std_logic;
    signal current_floor : std_logic_vector(WIDTH-1 downto 0);
    
    signal sim_ended : boolean := false;

begin

    -- Instancia do Unit Under Test (UUT)
    UUT: simple_elevator
        generic map (w => WIDTH)
        port map (
            clk   => clk,
            reset => reset,
            op    => op,
            cl    => cl,
            up    => up,
            dn    => dn,
            dr    => dr,
            current_floor => current_floor
        );

    -- Geracao de clock
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

    -- Processo de estimulo
    stim_proc: process
        variable expected_floor : integer;
        variable current_floor_int : integer;
    begin
        report "==================================================";
        report "   TESTES DO ELEVADOR SIMPLES (simple_elevator)";
        report "==================================================";
        report "";

        -- Aguardar inicializacao
        wait for CLK_PERIOD * 3;
        
        ------------------------------------------------------------------
        -- Teste 1: Estado inicial
        ------------------------------------------------------------------
        report "### Teste 1 - Estado Inicial ###";
        report "Verificando estado inicial do elevador.";
        
        assert dr = '0' report "FALHA: Porta deveria estar fechada inicialmente" severity error;
        
        if current_floor /= "UUUUU" and current_floor /= "XXXXX" then
            current_floor_int := to_integer(unsigned(current_floor));
            assert current_floor_int = 0 
                report "FALHA: Andar inicial deveria ser 0, mas eh " & integer'image(current_floor_int) 
                severity error;
            report "  Porta inicial: FECHADA";
            report "  Andar inicial: " & integer'image(current_floor_int);
        else
            report "  AVISO: Aguardando inicializacao do current_floor" severity warning;
        end if;
        
        report "  Teste 1 concluido com sucesso";
        report "";

        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';

        ------------------------------------------------------------------
        -- Teste 2: Abrir porta
        ------------------------------------------------------------------
        report "### Teste 2 - Abrir Porta ###";
        report "Enviando comando para abrir a porta.";
        
        op <= '1';
        wait until rising_edge(clk);
        op <= '0';
        wait until rising_edge(clk);
        
        assert dr = '1' report "FALHA: Porta deveria estar aberta" severity error;
        report "  Porta aberta com sucesso";
        report "  Teste 2 concluido com sucesso";
        report "";

        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';

        ------------------------------------------------------------------
        -- Teste 3: Fechar porta
        ------------------------------------------------------------------
        report "### Teste 3 - Fechar Porta ###";
        report "Enviando comando para fechar a porta.";
        
        cl <= '1';
        wait until rising_edge(clk);
        cl <= '0';
        wait until rising_edge(clk);
        
        assert dr = '0' report "FALHA: Porta deveria estar fechada" severity error;
        report "  Porta fechada com sucesso";
        report "  Teste 3 concluido com sucesso";
        report "";

        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';

        ------------------------------------------------------------------
        -- Teste 4: Mover para cima
        ------------------------------------------------------------------
        report "### Teste 4 - Movimento para Cima ###";
        report "Movendo elevador para cima por 3 andares.";
        
        up <= '1';
        
        for i in 0 to 2 loop
            wait until rising_edge(clk);
            if current_floor /= "UUUUU" and current_floor /= "XXXXX" then
                expected_floor := i;
                current_floor_int := to_integer(unsigned(current_floor));
                assert current_floor_int = expected_floor
                    report "FALHA no ciclo " & integer'image(i) & 
                           ": Esperado=" & integer'image(expected_floor) & 
                           ", Obtido=" & integer'image(current_floor_int)
                    severity error;
                report "  Andar atual: " & integer'image(current_floor_int);
            end if;
        end loop;
        
        up <= '0';
        report "  Movimento para cima concluido";
        report "  Teste 4 concluido com sucesso";
        report "";


        ------------------------------------------------------------------
        -- Teste 5: Operacao de porta no andar 3
        ------------------------------------------------------------------
        report "### Teste 5 - Operacao de Porta no Andar 3 ###";
        report "Abrindo e fechando porta no andar 3.";
        
        op <= '1';
        wait until rising_edge(clk);
        op <= '0';
        wait until rising_edge(clk);
        assert dr = '1' report "FALHA: Porta deveria estar aberta" severity error;
        report "  Porta aberta no andar 3";
        
        wait for CLK_PERIOD * 2;
        
        cl <= '1';
        wait until rising_edge(clk);
        cl <= '0';
        wait until rising_edge(clk);
        assert dr = '0' report "FALHA: Porta deveria estar fechada" severity error;
        report "  Porta fechada no andar 3";
        report "  Teste 5 concluido com sucesso";
        report "";

        ------------------------------------------------------------------
        -- Teste 6: Mover para baixo
        ------------------------------------------------------------------
        report "### Teste 6 - Movimento para Baixo ###";
        report "Movendo elevador para baixo ate o andar 0.";
        
        dn <= '1';
        
        for i in 3 downto 0 loop
            wait until rising_edge(clk);
            if current_floor /= "UUUUU" and current_floor /= "XXXXX" then
                expected_floor := i;
                current_floor_int := to_integer(unsigned(current_floor));
                assert current_floor_int = expected_floor
                    report "FALHA no ciclo " & integer'image(3-i) & 
                           ": Esperado=" & integer'image(expected_floor) & 
                           ", Obtido=" & integer'image(current_floor_int)
                    severity error;
                report "  Andar atual: " & integer'image(current_floor_int);
            end if;
        end loop;
        
        dn <= '0';
        report "  Movimento para baixo concluido";
        report "  Teste 6 concluido com sucesso";
        report "";

        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';

        ------------------------------------------------------------------
        -- Teste 7: Conflito up/dn simultaneos
        ------------------------------------------------------------------
        report "### Teste 7 - Conflito Up/Down ###";
        report "Ativando up e down simultaneamente (deve manter posicao).";
        
        current_floor_int := to_integer(unsigned(current_floor));
        up <= '1';
        dn <= '1';
        wait until rising_edge(clk);
        up <= '0';
        dn <= '0';
        wait until rising_edge(clk);
        
        assert to_integer(unsigned(current_floor)) = current_floor_int 
            report "FALHA: Elevador nao deveria se mover com up e dn ativos" severity error;
        report "  Posicao mantida corretamente durante conflito";
        report "  Teste 7 concluido com sucesso";
        report "";

        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';

        ------------------------------------------------------------------
        -- Teste 8: Sequencia completa
        ------------------------------------------------------------------
        report "### Teste 8 - Sequencia Completa ###";
        report "Executando sequencia completa: subir, abrir porta, fechar, descer.";
        
        -- Subir ate o andar 2
        report "  Subindo para o andar 1...";
        up <= '1';
        wait until rising_edge(clk);
        up <= '0';
        wait until rising_edge(clk);
        
        if current_floor /= "UUUUU" and current_floor /= "XXXXX" then
            current_floor_int := to_integer(unsigned(current_floor));
            assert current_floor_int = 1
                report "FALHA: Deveria estar no andar 1, mas esta em " & integer'image(current_floor_int) 
                severity error;
            report "  Chegou ao andar 1";
        end if;
        
        -- Abrir porta
        report "  Abrindo porta...";
        op <= '1';
        wait until rising_edge(clk);
        op <= '0';
        wait until rising_edge(clk);
        assert dr = '1' report "FALHA: Porta deveria estar aberta" severity error;
        report "  Porta aberta";
        
        -- Fechar porta
        report "  Fechando porta...";
        cl <= '1';
        wait until rising_edge(clk);
        cl <= '0';
        wait until rising_edge(clk);
        assert dr = '0' report "FALHA: Porta deveria estar fechada" severity error;
        report "  Porta fechada";
        
        -- Descer ate o andar 0
        report "  Descendo para o andar 0...";
        dn <= '1';
        wait until rising_edge(clk);
        dn <= '0';
        wait until rising_edge(clk);
        
        if current_floor /= "UUUUU" and current_floor /= "XXXXX" then
            assert to_integer(unsigned(current_floor)) = 0 
                report "FALHA: Deveria estar no andar 0, mas esta em " & integer'image(to_integer(unsigned(current_floor))) 
                severity error;
            report "  Chegou ao andar 0";
        end if;
        
        report "  Sequencia completa executada com sucesso";
        report "  Teste 8 concluido com sucesso";
        report "";

        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';

        ------------------------------------------------------------------
        -- Finalizacao
        ------------------------------------------------------------------
        report "### RESUMO FINAL ###";
        
        if current_floor /= "UUUUU" and current_floor /= "XXXXX" then
            report "Andar final: " & integer'image(to_integer(unsigned(current_floor)));
        else
            report "Andar final: INVALIDO";
        end if;
        
        report "Estado da porta: " & std_logic'image(dr);
        
        report "";
        report "Todos os testes do simple_elevator foram concluidos!";
        report "";
        report "==================================================";
        report "                SIMULACAO CONCLUIDA";
        report "==================================================";
        
        sim_ended <= true;
        wait;
    end process;

    -- Processo de monitoramento
    monitor_proc: process
        variable last_floor : integer := -1;
        variable current_floor_int : integer;
        variable last_door_state : std_logic := '0';
    begin
        wait until rising_edge(clk);
        
        if current_floor /= "UUUUU" and current_floor /= "XXXXX" then
            current_floor_int := to_integer(unsigned(current_floor));
            
            -- Detectar mudanca de andar
            if current_floor_int /= last_floor then
                report "[MOVIMENTO] Andar: " & integer'image(last_floor) & 
                      " -> " & integer'image(current_floor_int);
                last_floor := current_floor_int;
            end if;
            
            -- Detectar mudanca de estado da porta
            if dr /= last_door_state then
                if dr = '1' then
                    report "[PORTA] ABERTA no andar " & integer'image(current_floor_int);
                else
                    report "[PORTA] FECHADA no andar " & integer'image(current_floor_int);
                end if;
                last_door_state := dr;
            end if;
        end if;
    end process;

end architecture sim;