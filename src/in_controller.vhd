library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity in_controller is
  generic (w : natural := 5);
  port (
    clk               : in std_logic;
    int_floor_request : in std_logic_vector(31 downto 0); --botoes internos do elevador (devemos programar ainda o teclado)
    move_up_request   : in std_logic_vector (31 downto 0); -- pedido de subida externo (NOVO)
    move_dn_request   : in std_logic_vector (31 downto 0); -- pedido de descida externo (NOVO)
    current_floor     : out std_logic_vector(w-1 downto 0); -- andar atual do elevador
    status            : out std_logic_vector(1 downto 0); -- status do elevador: 00-parado, 10-subindo, 01-descendo (NOVO)
    intention         : out std_logic_vector(1 downto 0) -- intencao de movimento: 00-parado, 10-subindo, 01-descendo
  );
end in_controller;

architecture arch of in_controller is
    signal op_int            : std_logic := '0';
    signal cl_int            : std_logic := '0';
    signal up_int            : std_logic := '0';
    signal dn_int            : std_logic := '0';
    signal current_floor_int : std_logic_vector(w-1 downto 0);
    signal dr_int            : std_logic;
    signal intention_int     : std_logic_vector(1 downto 0) := "00";

    component simple_elevator is
        generic (w : natural := 5);
        port (
            clk            : in  std_logic;
            op             : in  std_logic; -- open door
            cl             : in  std_logic; -- close door
            up             : in  std_logic; -- move up
            dn             : in  std_logic; -- move down
            dr             : out std_logic; -- porta esta aberta
            current_floor  : out std_logic_vector(w-1 downto 0)
        );
    end component;

begin

    simple_elevator_inst: simple_elevator
        generic map(w => w)
        port map (
            clk            => clk,
            op             => op_int,
            cl             => cl_int,
            up             => up_int,
            dn             => dn_int,
            dr             => dr_int,
            current_floor  => current_floor
        );

    intention <= intention_int;

    process(clk)
        variable current_floor_int   : integer;
        variable added_calls         : integer;
        variable at_destination      : boolean;
        variable status_int          : boolean;
        variable call_exists         : boolean;
        variable left_floors         : std_logic_vector(31 downto 0);
        variable move_up_request_int : std_logic_vector(31 downto 0) := (others => '0');
        variable move_dn_request_int : std_logic_vector(31 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            current_floor_int := CONV_INTEGER(current_floor); --tem algo estranho aqui, o current floor esta lendo ou 1 andar a mais ou 1 andar a menos doq o normal
            -- tlvz o current_floor_int não esta sendo inicializado como 0 por padrão nsimple_elevatoremove_counterdc?

            move_up_request_int := move_up_request or move_up_request_int;
            move_dn_request_int := move_dn_request or move_dn_request_int;

            -- Verifica se chegou no destino
            if intention_int = "10" and move_up_request_int(current_floor_int) = '1' then
                move_up_request_int(current_floor_int) := '0';
                left_floors := move_up_request_int(current_floor_int downto 0);
                move_up_request_int(current_floor_int) := '1' when not (left_floors = (others => '0')) else '0';  -- Se intencao eh subir e o vetor de subir tem pedido no andar atual, apaga pedido
                at_destination := left_floors = (others => '0');
            elsif intention_int = "01" and move_dn_request_int(current_floor_int) = '1' then
                move_dn_request_int(current_floor_int) := '0';
                left_floors := move_dn_request_int(31 downto current_floor_int);
                move_dn_request_int(current_floor_int) := '1' when not (left_floors = (others => '0')) else '0'; -- Se intencao eh descer e o vetor de descer tem pedido no andar atual, apaga pedido
                at_destination := left_floors = (others => '0');
            else
                at_destination := true when move_up_request_int(current_floor_int) or move_dn_request_int(current_floor_int) else false; 
                move_up_request_int(current_floor_int) := '0';
                move_dn_request_int(current_floor_int) := '0';
            end if;
            end if;

            if at_destination then
                op_int <= '1';
                cl_int <= '0';
                up_int <= '0';
                dn_int <= '0';
            else
                -- Fecha a porta se tudo der errado    
                op_int <= '0';
                cl_int <= '1';

                -- Atualiza a existencia de chamadas
                if intention_int = "10" then
                    call_exists := move_up_request_int /= (others => '0'); -- se esta subindo, verifica se tem chamadas subindo
                elsif intention_int = "01" then
                    call_exists := move_dn_request_int /= (others => '0'); -- se esta descendo, verifica se tem chamadas descendo
                else
                    call_exists := (move_up_request_int /= (others => '0')) or (move_dn_request_int /= (others => '0')); -- se parado, verifica ambos
                end if;

                if not call_exists then
                    if intention_int = "10" then
                        call_exists := move_dn_request_int /= (others => '0'); -- se estava subindo e nao ha mais chamadas subindo, verifica se ha chamadas descendo
                    elsif intention_int = "01" then
                        call_exists := move_up_request_int /= (others => '0'); -- se estava descendo e nao ha mais chamadas descendo, verifica se ha chamadas subindo
                    end if;
                end if;
                if not call_exists then
                    intention_int <= "00"; -- se nao ha chamadas, para o elevador
                    status <= "00";
                    dn_int <= '0';
                    up_int <= '0';
                    -- pensar depois em fechar a porta se nao ha chamadas
                end if;
                if call_exists and intention_int = "00" then
                        if move_dn_request_int /= (others => '0') then
                            intention_int <= "01"; -- se parado e houver chamadas, decide a direcao baseado na primeira chamada
                        else
                            intention_int <= "10";
                        end if;
                end if;

                if intention_int /= "00" then
                    if intention_int = "10" then
                        left_floors := move_up_request_int(current_floor_int downto 0);
                        if left_floors /= (others => '0') then
                            status <= "10";
                            dn_int <= '0';
                            up_int <= '1';
                        else
                            status <= "01";
                            dn_int <= '1';
                            up_int <= '0';
                        end if;
                    else
                        left_floors := move_dn_request_int(31 downto current_floor_int);
                        if left_floors /= (others => '0') then
                            status <= "01";
                            dn_int <= '1';
                            up_int <= '0';
                        else
                            status <= "10";
                            dn_int <= '0';
                            up_int <= '1';
                        end if;
                    end if;
                end if;
            end if;

        current_floor <=  std_logic_vector(to_unsigned(current_floor_int, 5));
        intention <= intention_int;

    end process;

end arch;