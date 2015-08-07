----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:42:15 07/30/2015 
-- Design Name: 
-- Module Name:    SerialRX - Behavioral 
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

entity SerialRX is
    Port ( clk : in  STD_LOGIC;
           RsRx : in  STD_LOGIC;
           rx_shift : in  STD_LOGIC;
           rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
           rd_done_tick : out  STD_LOGIC);
end SerialRX;

architecture Behavioral of SerialRX is

-- states for the controller:
type state_type is (detect_start, count, shift, transfer, assert_rx);
signal PS, NS : state_type;
signal start_bit_detected : STD_LOGIC := '0';
signal transfer_on : STD_LOGIC := '0';

-- signals for the baud counter
constant baud_rate : integer := 115200;
constant clock_rate : integer := 1000000;
constant N : integer := clock_rate / baud_rate;
signal bits_read : integer := 0;
signal found_middle : STD_LOGIC := '0';

-- signal for bit counter 
signal bits_received : integer := 0;
signal all_bits_found : STD_LOGIC := '0';

-- signals for the synchronizer
signal sync_output, start_detected : STD_LOGIC := '0';
signal sync_data : STD_LOGIC_VECTOR (1 downto 0) := "00";

-- signals for the register
signal shift_output : STD_LOGIC_VECTOR (9 downto 0) := ( others => '0');
--signal shift_data : STD_LOGIC_VECTOR (9 downto 0) := ( others => '0');
signal shift_clear : STD_LOGIC;
signal shift_shift : STD_LOGIC;

-- signals for the load register
signal load_control : STD_LOGIC;
signal load_data : STD_LOGIC_VECTOR (7 downto 0) := ( others => '0');

begin

	-- synchronizer process
	synchronize : process(CLK, RsRx)
	begin
		-- on clock edge, set output to the MSB of the data inside the flip flops
		-- and then concatenate the input to the inside data
		if (rising_edge(CLK)) then
			sync_output <= sync_data(1);
			sync_data <= sync_data(0) & RsRx;
		end if;
	end process synchronize;
	
	-- shift register process
	shifting : process(CLK, shift_clear, shift_shift, shift_output)
	begin
		if (rising_edge(CLK)) then
			-- if clear is one, then set all of the data inside to 0
			if (shift_clear = '1') then
				shift_output <= (others => '0');
			else 
				-- if shift is 1, then we take the first 9 bits, 
				-- concatenate the output from the synchronizer, and we good
				if (shift_shift = '1') then
					shift_output <= sync_output & shift_output(9 downto 1);
				end if;
			end if;
		end if;
	end process shifting;
 
	-- 8 bit parallel load register
	load_register : process(CLK, load_control, shift_output)
	begin
		if (rising_edge(CLK)) then
			-- if enabled by control, we parallel load the output 
			-- 8 to 1 from the shift register
			if (load_control = '1') then
				load_data <= shift_output(8 downto 1);
				rx_data <= load_data;
			end if;
		end if;
	end process load_register;
	
	-- controller
	Controller_state : process (CLK)
	begin
		if (rising_edge(CLK)) then
			PS <= NS;
		end if;
	
	end process Controller_state;
	
	--controller
	Controller : process(PS, sync_output)
	begin
		-- default value for next state
		NS <= PS;
		case PS is
			-- when we are still detecting for the start bit
			-- then either bit detected and we switch states, or its not
			when detect_start => 
				if (sync_output = '0') then
					-- if it goes from 1 to 0, then we have found the start 
					-- we must update a signal to notify the rest of the system that 
					-- that bit has been found
					start_bit_detected <= '1';
					NS <= count;
				end if;
			when count =>
				shift_shift <= '1';
				start_bit_detected <= '0';
				transfer_on <= '1';
				-- if 10 bit are found, then we got onto transfer (precedence)
				if (all_bits_found = '1') then
					NS <= transfer;
				else 
				-- otherwise, we are still reading the data
					-- if it is the end of the cycle, then shift
					if (found_middle = '1') then
						NS <= shift;
					else 
						-- nothing
					end if;
				end if;
	
			when shift =>
				-- take bit from count, and put it into the end of the register and shift
				shift_shift <= '1';
				NS <= count;
			when transfer =>
				-- put all bits into output register
				load_register <= '1';
				NS <= assert_rx;
			when assert_rx =>
				rx_done <= '1';
				transfer_on <= '0';
				
		end case;
	end process Controller;
	
	-- baud counter
	Baud_Counter : process(CLK)
	begin
		if (rising_edge(CLK)) then
			-- if we have found the start bit, start counting
			if (start_bit_detected = '1' and transfer_on = '0') then
				-- if the number if bits read is less than N/2 - 1
				if (bits_read < ((N/2) - 1)) then
					bits_read <= bits_read + 1;
				else 
					-- indicate that we have found the middle of the first data bit
					bits_read <= 0;
					found_middle <= '1';
				end if;
			else if (transfer_on = '1') then
			-- data is reading in from a middle data bit
				if (bits_read < (N -1))  then
					bits_read <= bits_read + 1;
				else 
					-- indicate that we have found the middle of the first data bit
					bits_read <= 0;
					found_middle <= '1';
				end if;
			end if;
		end if;
	end process Baud_Counter;
				
	Bit_Counter : process(CLK)
	begin
		if (rising_edge(CLK)) then
		
			if bits_received = 11 then
				bits_received <= '0';
				all_bits_found <= '1';
			end if;
			
			if (found_middle = '1') then
				bits_received <= bits_received + 1;
			end if;
		end if;
	end process Bit_Counter;
	
end Behavioral;

