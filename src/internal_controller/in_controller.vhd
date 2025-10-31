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
    signal move_dn_next        : std_logic_vector(31 downto 0) := (others => '0');
    signal move_up_next        : std_logic_vector(31 downto 0) := (others => '0');
    signal current_floor_int   : integer range 0 to 31;
    signal next_floor_int      : integer range 0 to 31 := 0;
    signal status_int          : std_logic_vector(1 downto 0)  := (others => '0');
    signal at_destination_int  : boolean;
    signal call_dir            : std_logic_vector(1 downto 0)  := (others => '0');

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
            current_floor     : integer range 0 to 31;
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
            call_dir          : out std_logic_vector(1 downto 0)  := (others => '0')
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
            move_up_request   => move_up_request_int,
            move_dn_request   => move_dn_request_int,
            next_floor        => next_floor_int,
            current_floor     => current_floor_int,
            status            => status_int,
            intention         => intention_int,
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
            at_destination => at_destination_int,
            current_floor  => current_floor_int,
            next_floor     => next_floor_int,
            move_up_out    => move_up_request_int,
            move_dn_out    => move_dn_request_int
        );

    call_analyzer_inst: call_analyzer
        port map( 
            move_up_request   => move_up_request_int,
            move_dn_request   => move_dn_request_int,
            call_dir          => call_dir
        );

    current_floor <= std_logic_vector(to_unsigned(current_floor_int, w));
    intention <= intention_int;
    status <= status_int;

    process(clk, reset)
        variable current_floor_var   : integer;
        variable added_calls         : integer;
        variable left_floors         : std_logic_vector(31 downto 0);
        variable move_up_request_var : std_logic_vector(31 downto 0) := (others => '0');
        variable move_dn_request_var : std_logic_vector(31 downto 0) := (others => '0');
        variable zeros               : std_logic_vector(31 downto 0) := (others => '0');
        variable status_var          : std_logic_vector(1 downto 0)  := (others => '0');
        variable intention_var       : std_logic_vector(1 downto 0)  := (others => '0');

    begin
        if rising_edge(reset) then
            op_int <= '0';
            cl_int <= '0';
            up_int <= '0';
            dn_int <= '0';
            intention_int <= "00";
            status_int <= (others => '0');
        elsif rising_edge(clk) then
            current_floor_var := current_floor_int;
            intention_var := intention_int;

--==========================================================================
            -- Atualizando os vetores de chamadas baseando-se nas chamadas do clock passado e dos sinais que vem do controlador externo
            move_up_request_var := move_up_request_int;
            move_dn_request_var := move_dn_request_int;
              
            if at_destination_int then -- SEÇÃO RESPONSÁVEL POR PARAR E ABRIR A PORTA NO ANDAR DESTINO
                op_int <= '1';
                cl_int <= '0';
                up_int <= '0';
                dn_int <= '0';
            else 
                op_int <= '0';
                cl_int <= '1';
                
                if call_dir = "00" then
                        intention_int <= "00";
                        intention_var := "00";
                        status_int <= "00";
                        status_var := "00";
                        dn_int <= '0';
                        up_int <= '0';
                else
                    if call_dir = not intention_int then
                        intention_int <= not intention_int;
                        intention_var := intention_int;
                    end if;

                    if intention_var = "00" then
                        if call_dir = "10" or call_dir = "11"  then
                            intention_int <= "10";
                            intention_var := "10";
                        else
                            intention_int <= "01";
                            intention_var := "01";
                        end if;
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
        
    end process;

end arch;