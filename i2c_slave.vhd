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
    Port ( 	clk : in  STD_LOGIC;											-- Clock
				rst: in  STD_LOGIC;											-- Reset
				rdata			  : out std_logic_vector(7 downto 0);	-- Принятые данные
				receiving	  : out std_logic;							-- Slave осуществляет прием данных (высокий уровень)
				test			  : out std_logic; 							-- Для теста
            scl_pad_i     : in  std_logic;                    	-- i2c clock line input
            sda_pad_i     : in  std_logic;                    	-- i2c data line input
            sda_pad_o     : out std_logic;                    	-- i2c data line output
            sda_padoen_o  : out std_logic:='1'                 -- i2c data line output enable, active low
			  );
end i2c_slave;

architecture Behavioral of i2c_slave is

type tmem is array (0 to 15) of std_logic_vector(7 downto 0); 	-- Память 16 x 8 бит

shared variable mem:tmem;
shared variable breceiving:std_logic:='0';							-- Прием данных (высокий уровень)
shared variable scl_L:std_logic:='0';								  	-- Прошлое значение scl (на прошлом такте)
shared variable sda_L:std_logic:='0';									-- Прошлое значение sda (на прошлом такте)
shared variable ack:std_logic:='0';										-- Разрешение формарования сигнала подтверждения
shared variable r:std_logic:='0';										-- Запись slave-ом данных на шину (высокий уровень), Чтение slave-ом данных с шины (низкий уровень)
shared variable s:std_logic:='0';										-- Пропуск фронта scl для последующего корректного приема
shared variable adr:std_logic:='1';										-- Прием адреса устройства на шине I2C (высокий уровень)
shared variable madr:std_logic:='1';									-- Обработка принятого байта данных как адрес памяти(высокий уровень), Обработка принятого байта данных как данные для записи в память (низкий уровень)
shared variable memadr:integer range 0 to 15:=0;					-- Адрес памяти
shared variable bsda_padoen_o:std_logic:='1';						-- i2c data line output enable, active low
shared variable Data:std_logic_vector(7 downto 0):=(others=>'0'); 	-- Принятые данные
shared variable sData:std_logic_vector(7 downto 0):=(others=>'0'); 	-- Данные на отправку
shared variable sc:integer range 0 to 15:=0;							-- Счетчик принятых битов
shared variable ack_sc:integer range 0 to 55:=0;					-- Счетчик для формирования сигнала подтверждения
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
-- Формирование сигнала подтверждения	
		if (ack='1') then
			ack_sc:=ack_sc+1;
			if (ack_sc=55) then
				ack:='0';
				bsda_padoen_o:='1';
			end if;	
		end if;

-- Анализ сигналов на шине I2C
		if (breceiving='0')and(scl_pad_i='1')and(sda_pad_i='0')and(scl_L='1')and(sda_L='1') then -- Обнаружен сигнал start
-- Начало приема		
			breceiving:='1';
			sc:=0;
			s:='0';
			adr:='1';
			r:='0';
			data:=(others=>'0');
		elsif (breceiving='1')and(scl_pad_i='1')and(scl_L='0') then -- Прием бит
			if (s='0') then -- пропуск фронта scl для последующего корректного приема
				sc:=sc+1;
-- Анализ полученных бит по шине I2C				
				if (sc=9) then 
					sc:=0;
					if (adr='1')then -- Полученные биты являются адресом устройства на шине I2C
						if (data(7 downto 1)="1010001")then -- Сравнение полученного адреса с адресом slave устройства 
-- формирование сигнала подтверждения при совпадении адресов устройств						
							bsda_padoen_o:='0';				
							ack:='1';
							ack_sc:=0;
							r:=data(0); -- установка режима чтения или записи на шину I2C
							adr:='0'; -- Следующие принятые биты будут данными
						end if;
					else -- Полученные биты являются данными на шине I2C
						if (r='0')then -- Чтение slave-ом данных с шины
							if (madr='1')then -- Принятые данные являются адресом памяти
								madr:='0';-- Следующие данные будут данные для записи в память по принятому адресу
-- Декодирование адреса памяти									
								case data(3 downto 0) is
									when "0000" => 
										memadr:=0;
										sdata:=mem(0); -- Установка данных на отправку по принятому адресу
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
							else -- Принятые данные являются данные для записи в память
								mem(memadr):=data; -- Запись данных в память																
								madr:='1'; -- Следующие данные будут адресом памяти
							end if;								
-- формирование сигнала подтверждения после получения битов данных
							bsda_padoen_o:='0';				
							ack:='1';
							ack_sc:=0;									
						else
-- окончание передачи slave-ом бит
							madr:='1'; -- Следующие данные будут адресом памяти
							r:='0';
							bsda_padoen_o:='1';
						end if;					
						adr:='1';-- Следующие принятые биты будут адресом устройства
						s:='1';-- пропуск фронта scl для последующего корректного приема
					end if;
					data:=(others=>'0');				
				else -- Осуществляется прием/передача битов
					if (r='1')then	-- Передача битов slave-ом			
						bsda_padoen_o:=sData(7);
						sData:=sData(6 downto 0)&sData(7);					
					else -- Получение битов slave-ом
						data:=data(6 downto 0)&sda_pad_i;
					end if;	
				end if;
			else --s=0
				s:='0';
			end if;--s=1
		elsif (breceiving='1')and(r='0')and(scl_pad_i='1')and(sda_pad_i='1')and(scl_L='1')and(sda_L='0') then -- Обнаружен сигнал stop
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
