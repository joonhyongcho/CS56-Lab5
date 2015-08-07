----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:31:01 07/30/2015 
-- Design Name: 
-- Module Name:    TXDSynchronizer - Behavioral 
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

entity TXDSynchronizer is
    Port ( TXD_signal  : in  STD_LOGIC;
           Sync_Output : out  STD_LOGIC
			  CLK 		  : in STD_LOGIC		);
end TXDSynchronizer;

architecture Behavioral of TXDSynchronizer is

signal sync_data : std_logic_vector (1 downto 0) := "00";

begin

	synchronize : process(CLK, TXD_signal)
	begin
		if (rising_edge(CLK)) then
			sync_output <= sync_data(1);
			sync_data <= sync_data(0) & TXD_signal;
		end if;
	end process synchronize;

end Behavioral;

