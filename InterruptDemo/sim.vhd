--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:45:04 06/01/2015
-- Design Name:   
-- Module Name:   /home/xivid/Project/Interrupt/sim.vhd
-- Project Name:  Interrupt
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Interrupt
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sim IS
END sim;
 
ARCHITECTURE behavior OF sim IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Interrupt
    PORT(
         Ready : IN  std_logic_vector(1 to 4);
         maskset : IN  std_logic_vector(1 to 4);
         btn : IN  std_logic_vector(1 to 4);
         clk : IN  std_logic;
         Led : OUT  std_logic_vector(1 to 4);
         Status : OUT  std_logic_vector(1 to 4);
         seg : OUT  std_logic_vector(7 downto 1);
         an : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Ready : std_logic_vector(1 to 4) := (others => '0');
   signal maskset : std_logic_vector(1 to 4) := (others => '0');
   signal btn : std_logic_vector(1 to 4) := (others => '0');
   signal clk : std_logic := '0';

 	--Outputs
   signal Led : std_logic_vector(1 to 4);
   signal Status : std_logic_vector(1 to 4);
   signal seg : std_logic_vector(7 downto 1);
   signal an : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Interrupt PORT MAP (
          Ready => Ready,
          maskset => maskset,
          btn => btn,
          clk => clk,
          Led => Led,
          Status => Status,
          seg => seg,
          an => an
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		btn(2) <= '1';
		btn(2) <= '0' after 5 ns;
		btn(4) <= '1' after 5 ns;
		btn(4) <= '0' after 5 ns;
		maskset <= "1001";
		btn(3) <= '1' after 5 ns;
		btn(3) <= '0' after 5 ns;
		maskset <= "0000";
		btn(3) <= '1';
		btn(3) <= '0' after 5 ns;
      wait;
   end process;

END;
