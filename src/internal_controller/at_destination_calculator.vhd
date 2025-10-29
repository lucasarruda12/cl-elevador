library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity at_destination_calculator is
  generic (w : natural := 5);
  port (
    move_up_request   : in std_logic_vector (31 downto 0);
    move_dn_request   : in std_logic_vector (31 downto 0);
    next_floor        : in integer;
    status            : in std_logic_vector(1 downto 0);
    intention         : in std_logic_vector(1 downto 0);
    at_destination    : out boolean
  );
end at_destination_calculator;

architecture arch of at_destination_calculator is

  begin
    process(move_up_request, move_dn_request, next_floor, status, intention)
    variable move_up_request_var : std_logic_vector(31 downto 0) := move_up_request;
    variable move_dn_request_var : std_logic_vector(31 downto 0) := move_dn_request;
    variable zeros               : std_logic_vector(31 downto 0) := (others => '0'); 

    begin
    move_up_request_var(next_floor) := '0';
    move_dn_request_var(next_floor) := '0';
    
    at_destination <= (intention = "10" and status = "10" and move_up_request(next_floor) = '1') and -- int = subir, status = 1, prox andar = 1
                      ;







    --  at_destination <=   ((intention = "10" and move_up_request(next_floor) = '1')
    --                     and 
    --                    (((std_logic_vector(resize(unsigned(move_up_request_var(next_floor downto 0)), 32)) = zeros) 
    --                    and status = "01") or status = "10")) 
    --                     or ((intention = "01" and move_dn_request(next_floor) = '1')
    --                     and (((std_logic_vector(resize(unsigned(move_dn_request(31 downto next_floor)), 32)) = zeros) and status = "10") or status = "01"))
    --                     or (intention = "00" and (move_up_request(next_floor) = '1' or move_dn_request(next_floor) = '1'));

    
    end process;
end arch;