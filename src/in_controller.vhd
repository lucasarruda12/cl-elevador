library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity in_controller is
  generic (w : natural := 5);
  port (
    clk               : in std_logic;
    int_floor_request : in std_logic_vector(w-1 downto 0);
    ext_floor_request : in std_logic_vector(w-1 downto 0);
    fr                : out std_logic_vector(w-1 downto 0);
    intension         : out std_logic_vector(1 downto 0);
    request_vector    : out std_logic_vector(31 downto 0)
  );
end in_controller;

architecture arch of in_controller is
    signal op_int : std_logic := '0';
    signal cl_int : std_logic := '0';
    signal up_int : std_logic := '0';
    signal dn_int : std_logic := '0';
    signal fr_int : std_logic_vector(w-1 downto 0);
    signal dr_int : std_logic;
    signal intension_int : std_logic_vector(1 downto 0) := "00";
    signal request_vector_int : std_logic_vector(31 downto 0) := (others => '0');
    signal calls_count : integer := 0;
    signal prev_int_floor_request : std_logic_vector(w-1 downto 0) := (others => '0');
    signal prev_ext_floor_request : std_logic_vector(w-1 downto 0) := (others => '0');
    signal prev_request_vector : std_logic_vector(31 downto 0) := (others => '0');

    component llel is
        generic (w : natural := 5);
        port (
            clk : in  std_logic;
            op  : in  std_logic;
            cl  : in  std_logic;
            up  : in  std_logic;
            dn  : in  std_logic;
            dr  : out std_logic;
            fr  : out std_logic_vector(w-1 downto 0)
        );
    end component;

    function to_one_hot(idx : integer; size : integer) return std_logic_vector is
        variable result : std_logic_vector(size-1 downto 0) := (others => '0');
    begin
        if idx >= 0 and idx < size then
            result(idx) := '1';
        end if;
        return result;
    end function;

begin

    llel_inst: llel
        generic map(w => w)
        port map (
            clk => clk,
            op  => op_int,
            cl  => cl_int,
            up  => up_int,
            dn  => dn_int,
            dr  => dr_int,
            fr  => fr_int
        );

    fr <= fr_int;
    intension <= intension_int;
    request_vector <= request_vector_int;

    process(clk)
        variable currentFloor : integer;
        variable combinedRequest : std_logic_vector(31 downto 0);
        variable temp_int_floor : integer;
        variable temp_ext_floor : integer;
        variable new_calls_count : integer;
        variable has_request_above : boolean;
        variable has_request_below : boolean;
        variable next_intension : std_logic_vector(1 downto 0);
        variable at_destination : boolean;
        variable new_int_request : boolean;
        variable new_ext_request : boolean;
        variable need_full_scan : boolean;
    begin
        if rising_edge(clk) then
            currentFloor := CONV_INTEGER(unsigned(fr_int));
            temp_int_floor := CONV_INTEGER(unsigned(int_floor_request));
            temp_ext_floor := CONV_INTEGER(unsigned(ext_floor_request));

            -- Detecta novos pedidos (transição de 0 para 1)
            new_int_request := (int_floor_request /= prev_int_floor_request) and (int_floor_request /= (int_floor_request'range => '0'));
            new_ext_request := (ext_floor_request /= prev_ext_floor_request) and (ext_floor_request /= (ext_floor_request'range => '0'));

            -- Adiciona novos pedidos ao vetor existente
            combinedRequest := request_vector_int;
            if new_int_request then
                combinedRequest := combinedRequest or to_one_hot(temp_int_floor, 32);
            end if;
            if new_ext_request then
                combinedRequest := combinedRequest or to_one_hot(temp_ext_floor, 32);
            end if;

            -- Verifica se chegou no destino
            at_destination := (request_vector_int(currentFloor) = '1');

            -- Se chegou no destino, apaga o bit
            if at_destination then
                combinedRequest(currentFloor) := '0';
            end if;

            -- Atualiza calls_count incrementalmente
            new_calls_count := calls_count;
            
            -- Decrementa se chegou em um destino
            if at_destination then
                if new_calls_count > 0 then
                    new_calls_count := new_calls_count - 1;
                end if;
            end if;
            
            -- Incrementa se novo pedido está na direção atual
            if new_int_request then
                if intension_int = "10" and temp_int_floor > currentFloor then
                    new_calls_count := new_calls_count + 1;
                elsif intension_int = "01" and temp_int_floor < currentFloor then
                    new_calls_count := new_calls_count + 1;
                end if;
            end if;
            
            if new_ext_request then
                if intension_int = "10" and temp_ext_floor > currentFloor then
                    new_calls_count := new_calls_count + 1;
                elsif intension_int = "01" and temp_ext_floor < currentFloor then
                    new_calls_count := new_calls_count + 1;
                end if;
            end if;

            -- Determina se precisa fazer varredura completa
            need_full_scan := (intension_int = "00") or (new_calls_count = 0);
            
            next_intension := intension_int;
            
            if need_full_scan then
                -- Faz varredura completa apenas quando parado ou calls_count zerou
                has_request_above := false;
                has_request_below := false;
                new_calls_count := 0;
                
                case intension_int is
                    when "10" =>  -- Estava subindo mas zerou
                        -- Verifica abaixo
                        for i in 0 to currentFloor-1 loop
                            if combinedRequest(i) = '1' then
                                has_request_below := true;
                                new_calls_count := new_calls_count + 1;
                            end if;
                        end loop;
                        
                        if has_request_below then
                            next_intension := "01";
                        else
                            next_intension := "00";
                        end if;
                        
                    when "01" =>  -- Estava descendo mas zerou
                        -- Verifica acima
                        for i in currentFloor+1 to 31 loop
                            if combinedRequest(i) = '1' then
                                has_request_above := true;
                                new_calls_count := new_calls_count + 1;
                            end if;
                        end loop;
                        
                        if has_request_above then
                            next_intension := "10";
                        else
                            next_intension := "00";
                        end if;
                        
                    when others =>  -- Está parado
                        -- Verifica ambas direções
                        for i in currentFloor+1 to 31 loop
                            if combinedRequest(i) = '1' then
                                has_request_above := true;
                                exit;
                            end if;
                        end loop;
                        
                        for i in 0 to currentFloor-1 loop
                            if combinedRequest(i) = '1' then
                                has_request_below := true;
                                exit;
                            end if;
                        end loop;
                        
                        if has_request_above then
                            next_intension := "10";
                            -- Conta chamadas acima
                            new_calls_count := 0;
                            for i in currentFloor+1 to 31 loop
                                if combinedRequest(i) = '1' then
                                    new_calls_count := new_calls_count + 1;
                                end if;
                            end loop;
                        elsif has_request_below then
                            next_intension := "01";
                            -- Conta chamadas abaixo
                            new_calls_count := 0;
                            for i in 0 to currentFloor-1 loop
                                if combinedRequest(i) = '1' then
                                    new_calls_count := new_calls_count + 1;
                                end if;
                            end loop;
                        else
                            next_intension := "00";
                            new_calls_count := 0;
                        end if;
                end case;
            else
                -- Mantém a direção atual pois ainda há chamadas
                next_intension := intension_int;
            end if;

            -- Casos especiais para andares extremos
            if currentFloor = 0 and next_intension /= "00" then
                next_intension := "10";
            elsif currentFloor = 31 and next_intension /= "00" then
                next_intension := "01";
            end if;

            -- Atualiza sinais
            intension_int <= next_intension;
            request_vector_int <= combinedRequest;
            prev_int_floor_request <= int_floor_request;
            prev_ext_floor_request <= ext_floor_request;
            prev_request_vector <= combinedRequest;
            calls_count <= new_calls_count;

            -- Controle de porta e movimento
            if at_destination then
                op_int <= '1';
                cl_int <= '0';
                up_int <= '0';
                dn_int <= '0';
            elsif next_intension /= "00" and dr_int = '0' then
                op_int <= '0';
                cl_int <= '0';
                
                if next_intension = "10" then
                    up_int <= '1';
                    dn_int <= '0';
                elsif next_intension = "01" then
                    up_int <= '0';
                    dn_int <= '1';
                else
                    up_int <= '0';
                    dn_int <= '0';
                end if;
            elsif next_intension /= "00" and dr_int = '1' then
                op_int <= '0';
                cl_int <= '1';
                up_int <= '0';
                dn_int <= '0';
            else
                op_int <= '0';
                cl_int <= '0';
                up_int <= '0';
                dn_int <= '0';
            end if;

        end if;
    end process;

end arch;