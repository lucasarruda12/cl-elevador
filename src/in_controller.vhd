library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity in_controller is
  generic (w : natural := 5);
  port (
    clk               : in std_logic;
    int_floor_request : in std_logic_vector(31 downto 0);
    move_up_request   : in std_logic_vector (31 downto 0);
    move_dn_request   : in std_logic_vector (31 downto 0);
    current_floor     : out std_logic_vector(w-1 downto 0);
    status            : out std_logic_vector(1 downto 0);
    intention         : out std_logic_vector(1 downto 0)
  );
end in_controller;

architecture arch of in_controller is
    signal op_int              : std_logic := '0';
    signal cl_int              : std_logic := '0';
    signal up_int              : std_logic := '0';
    signal dn_int              : std_logic := '0';
    signal current_floor_int   : std_logic_vector(w-1 downto 0);
    signal dr_int              : std_logic;
    signal intention_int       : std_logic_vector(1 downto 0) := "00";
    signal move_up_request_int : std_logic_vector(31 downto 0) := (others => '0');
    signal move_dn_request_int : std_logic_vector(31 downto 0) := (others => '0');

    component simple_elevator is
        generic (w : natural := 5);
        port (
            clk            : in  std_logic;
            op             : in  std_logic;
            cl             : in  std_logic;
            up             : in  std_logic;
            dn             : in  std_logic;
            dr             : out std_logic;
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
            current_floor  => current_floor_int
        );

    current_floor <= current_floor_int;
    intention <= intention_int;

    process(clk)
        variable current_floor_var   : integer;
        variable next_floor_var      : integer;
        variable added_calls         : integer;
        variable at_destination      : boolean;
        variable call_exists         : boolean;
        variable left_floors         : std_logic_vector(31 downto 0);
        variable move_up_request_var : std_logic_vector(31 downto 0) := (others => '0');
        variable move_dn_request_var : std_logic_vector(31 downto 0) := (others => '0');
        variable zeros               : std_logic_vector(31 downto 0) := (others => '0');
        variable status_int          : std_logic_vector(1 downto 0)  := (others => '0');
        variable intention_var       : std_logic_vector(1 downto 0)  := (others => '0');

    begin
        if rising_edge(clk) then
            current_floor_var := CONV_INTEGER(current_floor_int);
            intention_var := intention_int;

            if up_int = '1' then
                next_floor_var := current_floor_var + 1;
            elsif dn_int = '1' then
                next_floor_var := current_floor_var - 1;
            else
                next_floor_var := current_floor_var;
            end if;

            move_up_request_var := move_up_request or move_up_request_int;
            move_dn_request_var := move_dn_request or move_dn_request_int;

            for i in 0 to 31 loop
                if int_floor_request(i) = '1' then
                    if i > current_floor_var then
                        move_up_request_var(i) := '1';
                    elsif i < current_floor_var then
                        move_dn_request_var(i) := '1';
                    end if;
                end if;
            end loop;

            if intention_int = "10" and move_up_request_var(next_floor_var) = '1' then
                if status_int = "01" then -- descendo com a intenção de subir
                    move_up_request_var(next_floor_var) := '0';
                    left_floors := std_logic_vector(resize(unsigned(move_up_request_var(next_floor_var downto 0)), 32));
                    at_destination := left_floors = zeros;
                    if not (left_floors = zeros) then
                        move_up_request_var(next_floor_var) := '1';
                        at_destination := (left_floors = zeros);
                    else
                        move_up_request_var(next_floor_var) := '0';
                        at_destination := left_floors = zeros;
                    end if;  -- Se intencao eh subir e o vetor de subir tem pedido no andar atual, apaga pedido
                elsif status_int = "10" then --subindo com a intenção de subir
                    move_up_request_var(next_floor_var) := '0';
                    left_floors := std_logic_vector(resize(unsigned(move_up_request_var(31 downto next_floor_var)), 32));
                    at_destination := true;
                end if;

            elsif intention_int = "01" and move_dn_request_var(next_floor_var) = '1' then
                if status_int = "10" then -- subindo com a intenção de descer
                    move_dn_request_var(next_floor_var) := '0'; 
                    left_floors := std_logic_vector(resize(unsigned(move_dn_request_var(31 downto next_floor_var)), 32));
                    at_destination := left_floors = zeros;
                    if not (left_floors = zeros) then
                        move_dn_request_var(next_floor_var) := '1';
                        at_destination := false;
                    else
                        move_dn_request_var(next_floor_var) := '0';
                        at_destination := true;
                    end if;
                elsif status_int = "01" then -- descendo com a intenção de descer
                        move_dn_request_var(next_floor_var) := '0';
                        left_floors := std_logic_vector(resize(unsigned(move_dn_request_var(next_floor_var downto 0)), 32));
                        at_destination := true;
                end if;
            else
                if move_up_request_var(next_floor_var) = '1' or move_dn_request_var(next_floor_var) = '1' then
                    at_destination := true;
                else
                    at_destination := false;
                end if;
                move_up_request_var(next_floor_var) := '0';
                move_dn_request_var(next_floor_var) := '0';
            end if;

            if at_destination then
                op_int <= '1';
                cl_int <= '0';
                up_int <= '0';
                dn_int <= '0';
            else
                op_int <= '0';
                cl_int <= '1';

                if intention_int = "10" then
                    call_exists := move_up_request_var /= zeros;
                elsif intention_int = "01" then
                    call_exists := move_dn_request_var /= zeros;
                else
                    call_exists := (move_up_request_var /= zeros) or (move_dn_request_var /= zeros);
                end if;

                if not call_exists then
                    if intention_int = "10" then
                        call_exists := move_dn_request_var /= zeros;
                        intention_int <= "00";
                        intention_var := "00";
                    elsif intention_int = "01" then
                        call_exists := move_up_request_var /= zeros;
                        intention_int <= "00";
                        intention_var := "00";
                    end if;
                end if;
                
                if not call_exists then
                    intention_int <= "00";
                    intention_var := "00";
                    status <= "00";
                    status_int := "00";
                    dn_int <= '0';
                    up_int <= '0';
                end if;
                
                if call_exists and intention_var = "00" then
                    if move_up_request_var /= zeros then
                        intention_int <= "10";
                        intention_var := "10";
                    else
                        intention_int <= "01";
                        intention_var := "01";
                    end if;
                end if;

                if intention_var /= "00" then --chamadas existem
                    if intention_var = "10" then
                        if status_int = "10" or status_int = "00" then
                            left_floors := std_logic_vector(resize(unsigned(move_up_request_var(31 downto next_floor_var)), 32));
                            if left_floors /= zeros then
                                status <= "10";
                                status_int := "10";
                                dn_int <= '0';
                                up_int <= '1';
                            else
                                status <= "01";
                                status_int := "01";
                                dn_int <= '1';
                                up_int <= '0';
                            end if;
                        elsif status_int = "01" then
                            left_floors := std_logic_vector(resize(unsigned(move_up_request_var(next_floor_var downto 0)), 32));
                            if left_floors /= zeros then
                                status <= "01";
                                status_int := "01";
                                dn_int <= '1';
                                up_int <= '0';
                            else
                                status <= "10";
                                status_int := "10";
                                dn_int <= '0';
                                up_int <= '1';
                            end if;
                        end if;
                    else -- intenção = 01
                        if status_int = "01" or status_int = "00" then --descendo com intenção de descer
                            left_floors := std_logic_vector(resize(unsigned(move_dn_request_var(next_floor_var downto 0)), 32));
                            if left_floors /= zeros then
                                status <= "01";
                                status_int := "01";
                                dn_int <= '1';
                                up_int <= '0';
                            else
                                status <= "10";
                                status_int := "10";
                                dn_int <= '0';
                                up_int <= '1';
                            end if;
                        elsif status_int = "10" then --subindo com a intenção de descer
                            left_floors := std_logic_vector(resize(unsigned(move_dn_request_var(31 downto next_floor_var)), 32));
                            if left_floors /= zeros then
                                status <= "10";
                                status_int := "10";
                                dn_int <= '0';
                                up_int <= '1';
                            else
                                status <= "01";
                                status_int := "01";
                                dn_int <= '1';
                                up_int <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        
            move_up_request_int <= move_up_request_var;
            move_dn_request_int <= move_dn_request_var;
        
        end if;
    end process;

end arch;