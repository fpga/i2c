----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:36:42 04/05/2011 
-- Design Name: 
-- Module Name:    Test_block - Behavioral 
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
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Test_block is
	    port   (
            clk      : in  std_logic;                    	-- clock 
            rst      : in  std_logic ;      		        -- reset            
            adr_o      : out  std_logic_vector(2 downto 0); -- register adress
            dat_o      : out std_logic_vector(7 downto 0); 	-- data
            we       : out  std_logic;                    	-- write enabling
            stb      : out  std_logic                    	-- strobe - core select
    );

end Test_block;

architecture Behavioral of Test_block is

        constant data_len:integer:=27;					-- data lenght

type tdata is array (0 to data_len-1) of integer;
type tbit is array (0 to data_len-1) of std_logic;

constaNT data:tdata:=( 		        	99,0,128,		-- initialization
										162,144,0,		-- slave adress with write
										12,16,0,		-- memory adress
										162,144,0,		-- slave adress with write
										172,16,0,		-- data writing									
										162,144,0,		-- slave adress with write
										12,16,0,		-- memory adress
										163,144,0,		-- slave adress with read
										8,104,0 		-- data reading
													);
													
constant adr:tdata:=( 		        	0,1,2,			-- initialization
										3,4,4,			-- slave adress with write
										3,4,4,			-- memory adress
										3,4,4,			-- slave adress with write
										3,4,4,			-- data writing
										3,4,4,			-- slave adress with write
										3,4,4,			-- memory adress
										3,4,4,			-- slave adress with read
										3,4,4 			-- data reading								
									  

													);

constant smd:tdata:=( 		        	2,2,2,			-- initialization
										2,2,5730,		-- slave adress with write
										2,2,5730,		-- memory adress
										2,2,5730,		-- slave adress with write
										2,2,5730,		-- data writing
										2,2,5730,		-- slave adress with write
										2,2,5730,		-- memory adress
										2,2,5730,		-- slave adress with read			
										2,2,6557		-- data reading 
													);

constant wed:tbit:=(			    	'1','1','1',	-- initialization
										'1','1','0',	-- slave adress with write
										'1','1','0',	-- memory adress
										'1','1','0',	-- slave adress with write
										'1','1','0',	-- data writing
										'1','1','0',	-- slave adress with write
										'1','1','0',	-- memory adress
										'1','1','0',	-- slave adress with read									
										'1','1','0'		-- data reading
													);

constant stbd:tbit:=(		        	'1','1','1',	-- initialization
										'1','1','0',	-- slave adress with write
                                        '1','1','0',	-- memory adress
										'1','1','0',	-- slave adress with write
                                        '1','1','0',	-- data writing
										'1','1','0',	-- slave adress with write
										'1','1','0',	-- memory adress
										'1','1','0',	-- slave adress with reade										
										'1','1','0'		-- data reading
													);
													
shared variable n:std_logic:='1';				-- load new data from array
shared variable s:integer:=0;				    -- counter
shared variable sm:integer range 0 to 8191:=0;  -- time for new data
shared variable c:integer:=0;				    -- place in array
begin
	process (clk,rst)
	begin
	--	if rst='0' then
			s:=0;
			n:='1';
			adr_o<=(others => '0');
			dat_o<=(others => '0');
			sm:=0;
			c:=0;
--		elsif (clk'event and clk='0') then
		
-- transfer new data from array			
--	if (n='1')then
				sm:=smd(c);
				adr_o<=conv_std_logic_vector(adr(c),3);
				dat_o<=conv_std_logic_vector(data(c),8);
				we<=wed(c);
				stb<=stbd(c);				
				n:='0';
			c:=c+1;				
				if (c=data_len)then 
-- in the beginning of the array after end 
					c:=0;
			--	end if;
			end if;			
-- wait for new	transfer from array		
			s:=s+1;	
			if (s=sm)then 
				s:=0;
				n:='1';				
			end if;			
	--	end if;--clk
	end process;	
end Behavioral;
