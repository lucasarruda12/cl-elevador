
library ieee;
use ieee.std_logic_1164.all;

entity at_destination_calculator_tb is
end at_destination_calculator_tb;

architecture tb of at_destination_calculator_tb is

    component at_destination_calculator
        port (move_up_request : in std_logic_vector (31 downto 0);
              move_dn_request : in std_logic_vector (31 downto 0);
              next_floor      : in integer := 0;
              status          : in std_logic_vector (1 downto 0);
              intention       : in std_logic_vector (1 downto 0);
              at_destination  : out boolean);
    end component;

    signal move_up_request : std_logic_vector (31 downto 0);
    signal move_dn_request : std_logic_vector (31 downto 0);
    signal next_floor      : integer := 0;
    signal status          : std_logic_vector (1 downto 0);
    signal intention       : std_logic_vector (1 downto 0);
    signal at_destination  : boolean;

begin

    dut : at_destination_calculator
    port map (move_up_request => move_up_request,
              move_dn_request => move_dn_request,
              next_floor      => next_floor,
              status          => status,
              intention       => intention,
              at_destination  => at_destination);

    stim_proc: process
        variable expected_floor : integer;
        variable current_floor_int : integer;
    begin
        wait for 10 ns;

        move_up_request <= (0 => '1', others => '0');
        move_dn_request <= (others => '0');
        next_floor      <= 0;
        status          <= "10";
        intention       <= "10";

        wait for 10 ns;

        move_up_request <= (others => '0');

        wait for 10 ns;

        move_up_request <= (6 => '1', others => '0');
        move_dn_request <= (others => '0');
        next_floor      <= 6;
        status          <= "01";
        intention       <= "10";

        wait for 10 ns;

        wait;
    end process;
end tb;