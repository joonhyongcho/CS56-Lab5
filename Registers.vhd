----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:37:17 07/30/2015 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Registers is
    Port ( shift_clear : in  STD_LOGIC;
           shift_shift : in  STD_LOGIC;
           shift_input : in  STD_LOGIC_VECTOR (9 downto 0);
           shift_output : out  STD_LOGIC;
           rx_data : out  STD_LOGIC_VECTOR (7 downto 0));
end Registers;

architecture Behavioral of Registers is

-- the data that is going to be put into the shift register and the load register
signal shift_data : STD_LOGIC_VECTOR (9 downto 0);
signal register_data : STD_LOGIC_VECTOR (7 downto 0);

begin

-- process to shift the register
	shift_input : process(CLK, shift_clear, shift_shift, shift_input)
	begin
		


end Behavioral;

