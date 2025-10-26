library ieee;

entity next_floor_calculator_tb is
end next_floor_calculator_tb;

architecture sim of next_floor_calculator_tb is

    -- Declaracao da unidade sob teste (UUT)
    component next_floor_calculator
        generic (w : natural := 5);
        port (
            up             : in std_logic;
            dn             : in std_logic;
            current_floor  : in std_logic_vector(w-1 downto 0);
            next_floor     : out std_logic_vector(w-1 downto 0)
        );
    end component;

    -- Sinais conectados a UUT
    signal up             : std_logic := '0';
    signal dn             : std_logic := '0';
    signal current_floor  : std_logic_vector(4 downto 0) := (others => '0');
    signal next_floor     : std_logic_vector(4 downto 0);