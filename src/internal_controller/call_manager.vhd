library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity call_manager is
    port (
        clk            : in std_logic;
        reset          : in std_logic;
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
end call_manager;

architecture arch of call_manager is
    -- Sinais intermediários
    signal merged_up        : std_logic_vector(31 downto 0);
    signal merged_dn        : std_logic_vector(31 downto 0);
    signal reg_up         : std_logic_vector(31 downto 0);
    signal reg_dn         : std_logic_vector(31 downto 0);
begin
    -- Merge (OR) com vetores externos
    merged_up <= move_up_ext or move_up_int;
    merged_dn <= move_dn_ext or move_dn_int;


    gen_requests: for i in 0 to 31 generate
        reg_up(i) <= '0' when (at_destination and i = next_floor) else
                     '1' when (int_request(i) = '1' and i >= current_floor) else
                     merged_up(i);
                        
        reg_dn(i) <= '0' when (at_destination and i = next_floor) else
                     '1' when (int_request(i) = '1' and i < current_floor) else
                     merged_dn(i);
    end generate;

    process(clk, reset)
        begin
            if reset = '1' then
                move_up_out <= (others => '0');
                move_dn_out <= (others => '0');
            elsif rising_edge(clk) then
                move_up_out <= reg_up;
                move_dn_out <= reg_dn;
            end if;
        end process;
end arch;