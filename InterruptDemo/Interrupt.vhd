----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:10:34 06/01/2015 
-- Design Name: 
-- Module Name:    Interrupt - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity Interrupt is
	Port(Ready  : in  STD_LOGIC_VECTOR(1 to 4);
		  maskset: in  STD_LOGIC_VECTOR(1 to 4);
        btn    : in  STD_LOGIC_VECTOR(0 to 4);
		  clk    : in  STD_LOGIC;
        Led    : out STD_LOGIC_VECTOR(1 to 4);
		  ProgressLed : out STD_LOGIC_VECTOR(1 to 4);
		  seg    : out STD_LOGIC_VECTOR(8 downto 1);
		  an     : out STD_LOGIC_VECTOR(3 downto 0)
		  );
end Interrupt;

architecture Behavioral of Interrupt is
	type DISPLAY is array(1 to 4) of STD_LOGIC_VECTOR(8 downto 1);
	signal digit: DISPLAY := ("11111111", "11111111", "11111111", "11111111"); --Initially display nothing
	signal MASK: STD_LOGIC_VECTOR(1 to 4) := "0000";
	type MASKWORDS is array(0 to 4) of STD_LOGIC_VECTOR(1 to 4); 
	signal maski: MASKWORDS := ("0000", "1111", "0111", "0011", "0001");
	signal js: std_logic_vector(26 downto 0) :="000000000000000000000000000";
	signal clkcount, clkseg: STD_LOGIC;
	signal shift: STD_LOGIC_VECTOR(3 downto 0) :="0111";
	signal INTR, INTA: std_logic_vector(1 to 4) := "0000";--中断请求
	--signal INTP: std_logic_vector(1 to 4) := "0000";--中断排队输出
	signal EINT: std_logic;--开关中断
	shared variable top: integer range 0 to 4:= 0; --Stack Top Pointer
	signal sigtop: integer range 0 to 4 := 0;
	type STACK4 is array(0 to 4) of integer range 0 to 4;
	shared variable stackInt, stackTime : STACK4 := (0,0,0,0,0);
	signal timeProgress: INTEGER range 0 to 4:=0;
	constant int2digit: DISPLAY := ("11111001","10100100","10110000","10011001");
begin
	--clock
	process(clk)
	begin
		if(rising_edge(clk)) then
			js <= js + '1';
		end if;
	end process;
	clkseg <= js(15);
	clkcount <= js(26);
	
	--set mask
	process(maskset, btn, maski)
	begin
		if maskset = "0000" then
			if btn(0) = '1' then
				Led <= MASK;
			elsif btn(1) = '1' then 
				Led <= maski(1);
			elsif btn(2) = '1' then
				Led <= maski(2); 
			elsif btn(3) = '1' then
				Led <= maski(3);
			elsif btn(4) = '1' then
				Led <= maski(4);
			else Led <= INTR;
			end if;
		else
			Led <= maskset;
			if btn(1) = '1' then
				maski(1) <= maskset;
			end if;
			if btn(2) = '1' then
				maski(2) <= maskset;
			end if;
			if btn(3) = '1' then
				maski(3) <= maskset;
			end if;
			if btn(4) = '1' then
				maski(4) <= maskset;
			end if;
		end if;
	end process;
	
	MASK <= maski(stackInt(top));

	--Query, Queue and Scene Preserving
	process(intr,eint,mask,maski,clkcount)
	begin
		if (rising_edge(clkcount)) then
			INTR <= (INTR and not INTA) or Ready;
			if (top = 0) then
				INTA <= "0000";
			end if;
			if (top > 0) then
				stackTime(top) := stackTime(top) + 1;
			end if;
			if (stackTime(top) = 5) then
				INTA(sigtop) <= '0';
				top := top - 1;
			end if;
			timeProgress <= stackTime(top);
			if (EINT='1' and top < 4) then
				if (((INTR(1) and not INTA(1)) = '1' or Ready(1) = '1') and MASK(1)='0') then
					EINT <= '0';
					INTA(1) <= '1';
					top := top + 1;
					stackInt(top) := 1;
					stackTime(top) := 0;
				elsif (((INTR(2) and not INTA(2)) = '1' or Ready(2) = '1') and MASK(2)='0') then 
					EINT <= '0';
					INTA(2) <= '1';
					top := top + 1;
					stackInt(top) := 2;
					stackTime(top) := 0;
				elsif (((INTR(3) and not INTA(3)) = '1' or Ready(3) = '1') and MASK(3)='0') then
					EINT <= '0';
					INTA(3) <= '1';
					top := top + 1;
					stackInt(top) := 3;
					stackTime(top) := 0;
				elsif (((INTR(4) and not INTA(4)) = '1' or Ready(4) = '1') and MASK(4)='0') then
					EINT <= '0';
					INTA(4) <= '1';
					top := top + 1;
					stackInt(top) := 4;
					stackTime(top) := 0;
				end if;
			else
				EINT <= '1';
			end if;
		end if;
		sigtop <= top;
	end process;

	--display
	process(clkseg)
	begin
		if(rising_edge(clkseg)) then
			shift(1)<=shift(0);
			shift(2)<=shift(1);
			shift(3)<=shift(2);
			shift(0)<=shift(3);
			an <= shift; 
			case shift is
				  when "0111" => seg <= digit(1);
				  when "1011" => seg <= digit(2);
				  when "1101" => seg <= digit(3);
				  when others => seg <= digit(4);
			end case;
		end if;
	end process;

	process(timeProgress)
	begin
		if (timeProgress=0) then
			ProgressLed <= "0000";
		elsif (timeProgress=1) then 
			ProgressLed <= "1000";
		elsif (timeProgress=2) then
			ProgressLed <= "1100";
		elsif (timeProgress=3) then
			ProgressLed <= "1110";
		else
			ProgressLed <= "1111";
		end if;
	end process;

	process(sigtop, clkcount)
	begin
		digit(1) <= "11111111";
		digit(2) <= "11111111";
		digit(3) <= "11111111";
		digit(4) <= "11111111";
		if sigtop = 1 then
			if clkcount = '1' then
				digit(1) <= int2digit(stackInt(1));
			else digit(1) <= "11111111";
			end if;
		elsif sigtop = 2 then
			digit(1) <= int2digit(stackInt(1));
			if clkcount = '1' then
				digit(2) <= int2digit(stackInt(2));
			else digit(2) <= "11111111";
			end if;
		elsif sigtop = 3 then
			digit(1) <= int2digit(stackInt(1));
			digit(2) <= int2digit(stackInt(2));
			if clkcount = '1' then
				digit(3) <= int2digit(stackInt(3));
			else digit(3) <= "11111111";
			end if;
		elsif sigtop = 4 then
			digit(1) <= int2digit(stackInt(1));
			digit(2) <= int2digit(stackInt(2));
			digit(3) <= int2digit(stackInt(3));
			if clkcount = '1' then
				digit(4) <= int2digit(stackInt(4));
			else digit(4) <= "11111111";
			end if;
		end if;
	end process;
end Behavioral;
