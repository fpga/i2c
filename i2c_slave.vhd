----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:12:22 04/15/2011 
-- Design Name: 
-- Module Name:    i2c_slave - Behavioral 
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
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_slave is
    Port ( 	clk : in  STD_LOGIC;										-- Clock
				rst: in  STD_LOGIC;										-- Reset
				rdata			  : out std_logic_vector(7 downto 0);	-- receiving data
				receiving	  : out std_logic;							-- receiving data (hight level)
		        test			  : out std_logic; 					    -- testing
            scl_pad_i     : in  std_logic;                    	-- i2c clock line input
            sda_pad_i     : in  std_logic;                    	-- i2c data line input
            sda_pad_o     : out std_logic;                    	-- i2c data line output
            sda_padoen_o  : out std_logic:='1'                 -- i2c data line output enable, active low
			  );
end i2c_slave;

architecture Behavioral of i2c_slave is

type tmem is array (0 to 15) of std_logic_vector(7 downto 0); 	-- memory 16 x 8 bit

shared variable mem:tmem;
shared variable breceiving:std_logic:='0';							    -- receiving data (hight level)
shared variable scl_L:std_logic:='0';								  	-- previous value scl
shared variable sda_L:std_logic:='0';									-- previous value sda
shared variable ack:std_logic:='0';										-- acknowledge signal
shared variable r:std_logic:='0';									-- writing by slave data to i2c (hight level), reading by slave data from i2c (low lewel)
shared variable s:std_logic:='0';									    -- skipping scl front for next correct reception
shared variable adr:std_logic:='1';										-- adress receiving (i2c hight level)
shared variable madr:std_logic:='1';									-- received byte is a memory adress (hight level), received byte is a data to save
shared variable memadr:integer range 0 to 15:=0;					-- memory adress
shared variable bsda_padoen_o:std_logic:='1';						-- i2c data line output enable, active low
shared variable Data:std_logic_vector(7 downto 0):=(others=>'0'); 	-- received data
shared variable sData:std_logic_vector(7 downto 0):=(others=>'0'); 	-- data to send
shared variable sc:integer range 0 to 15:=0;							-- received bit counter
shared variable ack_sc:integer range 0 to 55:=0;					-- counter for acknowledg signal
begin
process (clk,rst)
begin
	if (rst='0')then
			sc:=0;
			s:='0';
			adr:='1';
			r:='0';
			data:=(others=>'0');
			ack:='0';
			bsda_padoen_o:='1';
			ack_sc:=0;
			breceiving:='0';
			madr:='1';
			memadr:=0;
	elsif (clk'event and clk='1')then
-- aknowledge signal	
		if (ack='1') then
			ack_sc:=ack_sc+1;
			if (ack_sc=55) then
				ack:='0';
				bsda_padoen_o:='1';
			end if;	
		end if;

-- signals analysis
		if (breceiving='0')and(scl_pad_i='1')and(sda_pad_i='0')and(scl_L='1')and(sda_L='1') then -- find start signal
-- receiving start		
			breceiving:='1';
			sc:=0;
			s:='0'; 
			adr:='1';
			r:='0';
			data:=(others=>'0');
		elsif (breceiving='1')and(scl_pad_i='1')and(scl_L='0') then -- receive bits
                if (s='0') then -- skipping scl front for next correct reception
				sc:=sc+1;
-- received bits analysis				
				if (sc=9) then 
					sc:=0;
					if (adr='1')then -- received bits are adress
						if (data(7 downto 1)="1010001")then -- compare received adress with our adress 
-- acknowledge signal					
							bsda_padoen_o:='0';				
							ack:='1';
							ack_sc:=0;
							r:=data(0); -- writing or reading mode of I2C
							adr:='0'; -- next receiving bits are data
						end if;
					else -- received bits are data
						if (r='0')then -- slave reading data from I2C
							if (madr='1')then -- received bits are memory adress
								madr:='0';-- next receiving bits are data to save in memory
-- decoding memory adress									
								case data(3 downto 0) is
									when "0000" => 
										memadr:=0;
                                        sdata:=mem(0); -- data for sending to erceived adress
                                    when "0001" => 
										memadr:=1;
										sdata:=mem(1);
									when "0010" => 
										memadr:=2;
										sdata:=mem(2);
									when "0011" => 
										memadr:=3;
										sdata:=mem(3);
									when "0100" => 
										memadr:=4;
										sdata:=mem(4);
									when "0101" => 
										memadr:=5;
										sdata:=mem(5);
									when "0110" => 
										memadr:=6;
										sdata:=mem(6);
									when "0111" => 
										memadr:=7;
										sdata:=mem(7);
									when "1000" => 
										memadr:=8;
										sdata:=mem(8);
									when "1001" => 
										memadr:=9;
										sdata:=mem(9);
									when "1010" => 
										memadr:=10;
										sdata:=mem(10);
									when "1011" => 
										memadr:=11;
										sdata:=mem(11);
									when "1100" => 
										memadr:=12;
										sdata:=mem(12);
									when "1101" => 
										memadr:=13;
										sdata:=mem(13);
									when "1110" => 
										memadr:=14;
										sdata:=mem(14);
									when "1111" => 
										memadr:=15;
										sdata:=mem(15);

									when others => memadr:=0;
								end case;
                                else -- received bits are data for save
								mem(memadr):=data; -- writing data to memory																
								madr:='1'; -- next bits are memory adress
							end if;								
-- acknowledge signal after receiving after received data bits
							bsda_padoen_o:='0';				
							ack:='1';
							ack_sc:=0;									
						else
-- and of slave-writing to I2C
							madr:='1'; -- next reveiving bits are memorya adress
							r:='0';
							bsda_padoen_o:='1';
						end if;					
						adr:='1';-- next receiving bits are rezident adress
                        s:='1';-- skipping scl front for next correct reception
                        end if;
					data:=(others=>'0');				
				else -- writing/reading bits
					if (r='1')then	-- slave-writing bits			
						bsda_padoen_o:=sData(7);
						sData:=sData(6 downto 0)&sData(7);					
					else -- slave-receiving bits
						data:=data(6 downto 0)&sda_pad_i;
					end if;	
				end if;
			else --s=0
				s:='0';
			end if;--s=1
		elsif (breceiving='1')and(r='0')and(scl_pad_i='1')and(sda_pad_i='1')and(scl_L='1')and(sda_L='0') then -- find stop signal
			breceiving:='0';	
		end if;		
		scl_L:=scl_pad_i;
		sda_L:=sda_pad_i;			
	end if;
end process;
sda_pad_o<='0';
sda_padoen_o<=bsda_padoen_o;
receiving<=breceiving;
rdata<=data;
test<=s;
end Behavioral;
