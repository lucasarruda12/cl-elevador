library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity intention_manager is
    port (
        clk             : in std_logic;
        reset           : in std_logic;
        call_dir        : in std_logic_vector(1 downto 0) := (others => '0');
        intention   : out std_logic_vector(1 downto 0) := (others => '0')
    );
end intention_manager;

architecture arch of intention_manager is
    -- Sinais intermediários
    signal intention_op  : std_logic_vector(1 downto 0) := (others => '0'); 
    signal intention_st  : std_logic_vector(1 downto 0) := (others => '0');
    signal intention_reg : std_logic_vector(1 downto 0) := (others => '0');
begin

    intention_op <= not intention_reg when call_dir = (not intention_reg) else
                    intention_reg;

    intention_st <= "10" when call_dir(1) = '1' else "01";

    intention_reg <= "00" when call_dir = "00" else
                     intention_st when intention_op = "00" else
                     intention_op;

    process(clk, reset)
    begin
        if rising_edge(reset) then
            intention <= "00";
        elsif rising_edge(clk) then
            intention <= intention_reg;
        end if;
    end process;

end arch;