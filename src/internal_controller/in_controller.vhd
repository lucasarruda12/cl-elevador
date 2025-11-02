library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity in_controller is
  generic (w : natural := 5);
  port (
    clk               : in std_logic;
    reset             : in std_logic := '0';
    int_floor_request : in std_logic_vector(31 downto 0);
    move_up_request   : in std_logic_vector (31 downto 0);
    move_dn_request   : in std_logic_vector (31 downto 0);
    current_floor     : out std_logic_vector(w-1 downto 0) := (others => '0');
    status            : out std_logic_vector(1 downto 0) := (others => '0');
    intention         : out std_logic_vector(1 downto 0);
    dr                : out std_logic
  );
end in_controller;

architecture arch of in_controller is
    signal op_int              : std_logic := '0';
    signal cl_int              : std_logic := '0';
    signal up_int              : std_logic := '0';
    signal dn_int              : std_logic := '0';
    signal intention_int       : std_logic_vector(1 downto 0) := "00";
    signal move_up_request_int : std_logic_vector(31 downto 0) := (others => '0');
    signal move_dn_request_int : std_logic_vector(31 downto 0) := (others => '0');
    signal move_up_reg         : std_logic_vector(31 downto 0) := (others => '0');
    signal move_dn_reg         : std_logic_vector(31 downto 0) := (others => '0');
    signal current_floor_int   : integer range 0 to 31;
    signal next_floor_int      : integer range 0 to 31 := 0;
    signal status_int          : std_logic_vector(1 downto 0)  := (others => '0');
    signal at_destination_int  : boolean;
    signal call_dir            : std_logic_vector(1 downto 0)  := (others => '0');
    
    -- Sinais de pipeline para sincronização
    signal at_destination_delayed : boolean;
    signal call_dir_delayed       : std_logic_vector(1 downto 0);
    signal intention_delayed      : std_logic_vector(1 downto 0);

    component simple_elevator is
        port (
            clk            : in  std_logic;
            reset          : in  std_logic; 
            op             : in  std_logic;
            cl             : in  std_logic;
            up             : in  std_logic;
            dn             : in  std_logic;
            dr             : out std_logic;
            current_floor  : out integer range 0 to 31
        );
    end component;

    component next_floor_calculator is
        port (
            up             : in std_logic;
            dn             : in std_logic;
            current_floor  : in integer range 0 to 31;
            next_floor     : out integer range 0 to 31
        );
    end component;

    component at_destination_calculator is
        port (
            move_up_request   : in std_logic_vector (31 downto 0);
            move_dn_request   : in std_logic_vector (31 downto 0);
            next_floor        : in integer range 0 to 31;
            current_floor     : in integer range 0 to 31;
            status            : in std_logic_vector(1 downto 0);
            intention         : in std_logic_vector(1 downto 0);
            at_destination    : out boolean
        );
    end component;
    
    component call_manager is
        port (
            clk            : in  std_logic;
            reset          : in  std_logic; 
            move_up_ext    : in std_logic_vector (31 downto 0);
            move_dn_ext    : in std_logic_vector (31 downto 0);
            move_up_int    : in std_logic_vector (31 downto 0);
            move_dn_int    : in std_logic_vector (31 downto 0);
            int_request    : in std_logic_vector (31 downto 0);
            at_destination : in boolean;
            current_floor  : in integer range 0 to 31;
            next_floor     : in integer range 0 to 31;
            move_up_out    : out std_logic_vector (31 downto 0);
            move_dn_out    : out std_logic_vector (31 downto 0)
        );
    end component;

    component call_analyzer is
        port ( 
            move_up_request   : in std_logic_vector (31 downto 0);
            move_dn_request   : in std_logic_vector (31 downto 0);
            call_dir          : out std_logic_vector(1 downto 0)
        );
    end component;

    component intention_manager is
        port (
            clk             : in std_logic;
            reset           : in std_logic;
            call_dir        : in std_logic_vector(1 downto 0);
            intention       : out std_logic_vector(1 downto 0)
        );
    end component;

begin
    -- Mecanismo do elevador
    simple_elevator_inst: simple_elevator
        port map (
            clk            => clk,
            reset          => reset,
            op             => op_int,
            cl             => cl_int,
            up             => up_int,
            dn             => dn_int,
            dr             => dr,
            current_floor  => current_floor_int
        );

    -- Calculo do proximo andar
    next_floor_calculator_inst: next_floor_calculator
        port map (
            up             => up_int,
            dn             => dn_int,
            current_floor  => current_floor_int,
            next_floor     => next_floor_int
        );

    at_destination_inst: at_destination_calculator
        port map(
            move_up_request   => move_up_reg,  -- Usa versão registrada
            move_dn_request   => move_dn_reg,  -- Usa versão registrada
            next_floor        => next_floor_int,
            current_floor     => current_floor_int,
            status            => status_int,
            intention         => intention_delayed,
            at_destination    => at_destination_int
        );

    call_manager_inst: call_manager
        port map(
            clk            => clk,
            reset          => reset,
            move_up_ext    => move_up_request,
            move_dn_ext    => move_dn_request,
            move_up_int    => move_up_request_int,
            move_dn_int    => move_dn_request_int,
            int_request    => int_floor_request,
            at_destination => at_destination_delayed, -- Usa versão atrasada
            current_floor  => current_floor_int,
            next_floor     => next_floor_int,
            move_up_out    => move_up_request_int,
            move_dn_out    => move_dn_request_int
        );

    call_analyzer_inst: call_analyzer
        port map( 
            move_up_request   => move_up_reg,  -- Usa versão registrada
            move_dn_request   => move_dn_reg,  -- Usa versão registrada
            call_dir          => call_dir
        );
        
    intention_manager_inst: intention_manager
        port map(
            clk             => clk,
            reset           => reset,
            call_dir        => call_dir_delayed, -- Usa versão atrasada
            intention       => intention_int
        );

    -- PROCESSO DE SINCRONIZAÇÃO
    sync_process: process(clk, reset)
    begin
        if reset = '1' then
            move_up_reg <= (others => '0');
            move_dn_reg <= (others => '0');
            at_destination_delayed <= false;
            call_dir_delayed <= "00";
            intention_delayed <= "00";
        elsif rising_edge(clk) then
            -- Registra os sinais para quebrar dependências circulares
            move_up_reg <= move_up_request_int;
            move_dn_reg <= move_dn_request_int;
            at_destination_delayed <= at_destination_int;
            call_dir_delayed <= call_dir;
            intention_delayed <= intention_int;
        end if;
    end process;

    -- PROCESSO PRINCIPAL DE CONTROLE
    control_process: process(clk, reset)
        variable left_floors : std_logic_vector(31 downto 0);
        variable zeros       : std_logic_vector(31 downto 0) := (others => '0');
    begin
        if reset = '1' then
            op_int <= '0';
            cl_int <= '0';
            up_int <= '0';
            dn_int <= '0';
            status_int <= "00";
        elsif rising_edge(clk) then
            if at_destination_int then  -- Usa versão atualizada
                -- Parar e abrir porta
                op_int <= '1';
                cl_int <= '0';
                up_int <= '0';
                dn_int <= '0';
            else
                -- Fechar porta e mover
                op_int <= '0';
                cl_int <= '1';
                
                if call_dir_delayed = "00" then  -- Usa versão atrasada
                    -- Sem chamadas
                    status_int <= "00";
                    dn_int <= '0';
                    up_int <= '0';
                else
                    -- Com chamadas
                    if intention_delayed = "10" then -- Usa versão atrasada
                        -- Lógica para intenção de subir
                        if status_int = "10" or status_int = "00" then
                            -- Verificar chamadas acima
                            left_floors := (others => '0');
                            for i in next_floor_int + 1 to 31 loop
                                left_floors(i) := move_up_reg(i);  -- Usa versão registrada
                            end loop;
                            
                            if left_floors /= zeros then
                                status_int <= "10";
                                dn_int <= '0';
                                up_int <= '1';
                            else
                                status_int <= "01";
                                dn_int <= '1';
                                up_int <= '0';
                            end if;
                        elsif status_int = "01" then
                            -- Verificar chamadas abaixo
                            left_floors := (others => '0');
                            for i in 0 to next_floor_int - 1 loop
                                left_floors(i) := move_up_reg(i);  -- Usa versão registrada
                            end loop;
                            
                            if left_floors /= zeros then
                                status_int <= "01";
                                dn_int <= '1';
                                up_int <= '0';
                            else
                                status_int <= "10";
                                dn_int <= '0';
                                up_int <= '1';
                            end if;
                        end if;
                    elsif intention_delayed = "01" then -- Usa versão atrasada
                        -- Lógica para intenção de descer (similar)
                        if status_int = "01" or status_int = "00" then
                            left_floors := (others => '0');
                            for i in 0 to next_floor_int - 1 loop
                                left_floors(i) := move_dn_reg(i);  -- Usa versão registrada
                            end loop;
                            
                            if left_floors /= zeros then
                                status_int <= "01";
                                dn_int <= '1';
                                up_int <= '0';
                            else
                                status_int <= "10";
                                dn_int <= '0';
                                up_int <= '1';
                            end if;
                        elsif status_int = "10" then
                            left_floors := (others => '0');
                            for i in next_floor_int + 1 to 31 loop
                                left_floors(i) := move_dn_reg(i);  -- Usa versão registrada
                            end loop;
                            
                            if left_floors /= zeros then
                                status_int <= "10";
                                dn_int <= '0';
                                up_int <= '1';
                            else
                                status_int <= "01";
                                dn_int <= '1';
                                up_int <= '0';
                            end if;
                        end if;
                    else
                        -- Intenção inválida
                        status_int <= "00";
                        up_int <= '0';
                        dn_int <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    current_floor <= std_logic_vector(to_unsigned(current_floor_int, w));
    intention <= intention_int;
    status <= status_int;
end arch;