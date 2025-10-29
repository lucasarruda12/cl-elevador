library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity call_manager is
    port (
        clk            : in std_logic;
        move_up        : in std_logic_vector (31 downto 0);
        move_dn        : in std_logic_vector (31 downto 0);
        move_up_int    : in std_logic_vector (31 downto 0);
        move_dn_int    : in std_logic_vector (31 downto 0);
        int_request    : in std_logic_vector (31 downto 0);
        at_destination : in boolean;
        no_calls_left  : in boolean;
        status         : in std_logic_vector(1 downto 0);
        current_floor  : in integer range 0 to 31;
        next_floor     : in integer range 0 to 31;
        move_up_out    : out std_logic_vector (31 downto 0);
        move_dn_out    : out std_logic_vector (31 downto 0)
    );
end call_manager;

architecture arch of call_manager is
    -- Sinais intermediários
    signal merged_up        : std_logic_vector(31 downto 0);
    signal merged_dn        : std_logic_vector(31 downto 0);
    signal with_move_up_int : std_logic_vector(31 downto 0);
    signal with_move_dn_int : std_logic_vector(31 downto 0);
    signal final_up         : std_logic_vector(31 downto 0);
    signal final_dn         : std_logic_vector(31 downto 0);
    
    -- Sinais de controle para clear
    signal clear_up      : boolean;
    signal clear_dn      : boolean;
    
begin
    -- Merge (OR) com vetores externos
    merged_up <= move_up or move_up_int;
    merged_dn <= move_dn or move_dn_int;
    
    -- Processar chamadas internas- adicionar chamadas baseado na posição
    gen_int_request_up: for i in 0 to 31 generate
        with_move_up_int(i) <= '1' when (int_request(i) = '1' and i > current_floor) else merged_up(i);
    end generate;
    
    gen_int_request_dn: for i in 0 to 31 generate
        with_move_dn_int(i) <= '1' when (int_request(i) = '1' and i < current_floor) else merged_dn(i);
    end generate;
    
    -- Lógica de clear baseada em at_destination, status e no_callls_left
    
    -- Clear move_up(next_floor) quando:
    -- - status = "10" (subindo) E at_destination
    -- - OU status = "01" (descendo) E at_destination E no_calls_left
    clear_up <= (at_destination and 
                    ((status = "10") or 
                     (status = "01" and no_calls_left)));
    
    -- Clear move_dn(next_floor) quando:
    -- - status = "10" (subindo) E at_destination E no_calls_left
    -- - OU status = "01" (descendo) E at_destination
    clear_dn <= (at_destination and 
                    ((status = "10" and no_calls_left) or 
                     (status = "01")));

    -- Aplicar clears
    gen_clear_a: for i in 0 to 31 generate
        final_up(i) <= '0' when (clear_up and i = next_floor) 
                      else with_move_up_int(i);
    end generate;
    
    gen_clear_b: for i in 0 to 31 generate
        final_dn(i) <= '0' when (clear_dn and i = next_floor) 
                      else with_move_dn_int(i);
    end generate;
    
    process(clk)
    begin
        if rising_edge(clk) then
            move_up_out <= final_up;
            move_dn_out <= final_dn;
        end if;
    end process;
end arch;