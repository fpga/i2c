----------------------------------------------------------------------------------
-- Company:
-- Engineer: 
-- 
-- Create Date:    21:50:03 04/05/2011 
-- Design Name: 
-- Module Name:    i2c_main - Behavioral 
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

entity i2c_main is
   port   (
            -- wishbone signals
            wb_clk_i      : in  std_logic;                    -- master clock input
            wb_rst_i      : in  std_logic ;             -- synchronous active high reset
            arst_i        : in  std_logic ;    -- asynchronous reset
            adr     	  	  : in  std_logic_vector(2 downto 0); -- lower address bits
            adr_o   	  	  : out  std_logic_vector(2 downto 0); -- lower address bits
				
            dat_i         : in  std_logic_vector(7 downto 0); -- Databus  
				datint_o		  : out  std_logic_vector(7 downto 0); -- Databus 
				dat_o         : out std_logic_vector(7 downto 0); -- Databus output				
            we            : in  std_logic;                    -- Write enable input
            stb           : in  std_logic;                    -- Strobe signals / core select signal
            we_o            : out  std_logic;                    -- Write enable input
            stb_o           : out  std_logic;                    -- Strobe signals / core select signal

            cyc           : in  std_logic;                    -- Valid bus cycle input
            wb_ack_o      : out std_logic;                    -- Bus cycle acknowledge output
            wb_inta_o     : out std_logic;                    -- interrupt request output signal

            -- i2c lines
            scl     : inout std_logic;                    -- i2c clock line
				sda     : inout std_logic;                	     -- i2c data line 
            scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low            
            sda_padoen_o  : out std_logic;                     -- i2c data line output enable, active low
				
				--test
				test          : in  std_logic;                    -- test
				test2			  : out std_logic; 
				
				--slave
				slave_clk     : in  std_logic;                    -- clk

				slave_data			  : out std_logic_vector(7 downto 0);
				slave_receiving	  : out std_logic; 
            slave_scl  			  : in  std_logic;                    -- i2c clock line input
            slave_sda 		     : inout  std_logic;                    -- i2c data line input
            slave_sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
    );
end i2c_main;

architecture Behavioral of i2c_main is
	component test_block is
	    port   (
            -- wishbone signals
            clk      : in  std_logic;                    -- clock 
            rst      : in  std_logic ;      		        --  reset            
            adr_o      : out  std_logic_vector(2 downto 0); -- lower address bits
            dat_o      : out std_logic_vector(7 downto 0); -- Databus output
            we       : out  std_logic;                    -- Write enable input
            stb      : out  std_logic                    -- Strobe signals / core select signal
--            cyc      : out  std_logic                    -- Valid bus cycle input

    );		
	end component;
	
	component i2c_slave is
    Port ( clk : in  STD_LOGIC;
				rst : in std_logic;
				rdata			  : out std_logic_vector(7 downto 0);
				receiving	  : out std_logic; 
				test			  : out std_logic; 
            scl_pad_i     : in  std_logic;                    -- i2c clock line input
--            scl_pad_o     : out std_logic;                    -- i2c clock line output
--            scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
            sda_pad_i     : in  std_logic;                    -- i2c data line input
            sda_pad_o     : out std_logic;                    -- i2c data line output
            sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
			  );
	end component;

	
	component i2c_master_top is
	    port   (
            -- wishbone signals
            wb_clk_i      : in  std_logic;                    -- master clock input
            wb_rst_i      : in  std_logic ;      		        -- synchronous active high reset
            arst_i        : in  std_logic ;    	   				-- asynchronous reset
            wb_adr_i      : in  std_logic_vector(2 downto 0); -- lower address bits
            wb_dat_i      : in  std_logic_vector(7 downto 0); -- Databus input
            wb_dat_o      : out std_logic_vector(7 downto 0); -- Databus output
            wb_we_i       : in  std_logic;                    -- Write enable input
            wb_stb_i      : in  std_logic;                    -- Strobe signals / core select signal
            wb_cyc_i      : in  std_logic;                    -- Valid bus cycle input
            wb_ack_o      : out std_logic;                    -- Bus cycle acknowledge output
            wb_inta_o     : out std_logic;                    -- interrupt request output signal

            -- i2c lines
            scl_pad_i     : in  std_logic;                    -- i2c clock line input
            scl_pad_o     : out std_logic;                    -- i2c clock line output
            scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
            sda_pad_i     : in  std_logic;                    -- i2c data line input
            sda_pad_o     : out std_logic;                    -- i2c data line output
            sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
    );
	end component;
   
	signal wb_adr      : std_logic_vector(2 downto 0); -- lower address bits
	signal wb_dat_i      : std_logic_vector(7 downto 0); -- Databus 
	signal wb_dat_o      : std_logic_vector(7 downto 0); -- Databus 
	signal wb_we_i       : std_logic;                    -- Write enable input
	signal wb_stb_i      : std_logic;                    -- Strobe signals / core select signal
	signal wb_cyc_i      : std_logic;                    -- Valid bus cycle input

	signal tadr_o      : std_logic_vector(2 downto 0); -- lower address bits
	signal tdat_o      : std_logic_vector(7 downto 0); -- Databus 
	signal twe       : std_logic;                    -- Write enable input
	signal tstb      : std_logic;                    -- Strobe signals / core select signal
	--signal tcyc      : std_logic;                    -- Valid bus cycle input


            -- i2c lines
	signal scl_pad_i     : std_logic;                    -- i2c clock line input
	signal scl_pad_o     : std_logic;                    -- i2c clock line output
	signal scl_padoen_oe  : std_logic;                    -- i2c clock line output enable, active low
	signal sda_pad_i     : std_logic;                    -- i2c data line input
	signal sda_pad_o     : std_logic;                    -- i2c data line output
	signal sda_padoen_oe  : std_logic;                     -- i2c data line output enable, active low

	signal slave_scl_pad_i     : std_logic;                    -- i2c clock line input
--	signal slave_scl_pad_o     : std_logic;                    -- i2c clock line output
--	signal slave_scl_padoen_oe  : std_logic;                    -- i2c clock line output enable, active low
	signal slave_sda_pad_i     : std_logic;                    -- i2c data line input
	signal slave_sda_pad_o     : std_logic;                    -- i2c data line output
	signal slave_sda_padoen_oe  : std_logic;                     -- i2c data line output enable, active low


begin


	I2C_controller_Slave: i2c_slave
	port map (
				clk => slave_clk,
				rdata => slave_data,
				rst => arst_i,
				test => test2,
				receiving => slave_receiving,
            scl_pad_i => slave_scl_pad_i,                   -- i2c clock line input
--            scl_pad_o => slave_scl_pad_o,                   -- i2c clock line output
--            scl_padoen_o => slave_scl_padoen_oe,                    -- i2c clock line output enable, active low
            sda_pad_i => slave_sda_pad_i,                      -- i2c data line input
            sda_pad_o => slave_sda_pad_o,                       -- i2c data line output
            sda_padoen_o => slave_sda_padoen_oe                     -- i2c data line output enable, active low
	
	);
	TB:TEST_BLOCK
	port map (
            clk => wb_clk_i,          	  -- clock 
            rst => arst_i,         		      	  --  reset            
            adr_o => tadr_o,  							  -- lower address bits
            dat_o => tdat_o,  		 					  -- Databus output
            we => twe,                          -- Write enable input
            stb => tstb                         -- Strobe signals / core select signal
--            cyc => tcyc                          -- Valid bus cycle input
	
    );

  i2c_controller: i2c_master_top
    port map (
            wb_clk_i  => wb_clk_i,      -- master clock input
            wb_rst_i  => wb_rst_i,                -- synchronous active high reset
            arst_i    => arst_i,          -- asynchronous reset
            wb_adr_i  => wb_adr,     -- lower address bits
            wb_dat_i  => wb_dat_i,     -- Databus input
            wb_dat_o  => wb_dat_o,     -- Databus output
            wb_we_i   => wb_we_i,                       -- Write enable input
            wb_stb_i  => wb_stb_i,                        -- Strobe signals / core select signal
            wb_cyc_i  => wb_cyc_i,                         -- Valid bus cycle input
            wb_ack_o  => wb_ack_o,                         -- Bus cycle acknowledge output
            wb_inta_o => wb_inta_o,                      -- interrupt request output signal

            -- i2c lines
            scl_pad_i => scl_pad_i,                       -- i2c clock line input
            scl_pad_o => scl_pad_o,                       -- i2c clock line output
            scl_padoen_o => scl_padoen_oe,                   -- i2c clock line output enable, active low
            sda_pad_i => sda_pad_i,                     -- i2c data line input
            sda_pad_o => sda_pad_o,                     -- i2c data line output
            sda_padoen_o => sda_padoen_oe                   -- i2c data line output enable, active low 		
	  );

scl <= scl_pad_o when (scl_padoen_oe = '0') else 'Z';
sda <= sda_pad_o when (sda_padoen_oe = '0') else 'Z';
scl_pad_i <= scl;
sda_pad_i <= sda;


--slave_scl <= slave_scl_pad_o when (slave_scl_padoen_oe = '0') else 'Z';
slave_sda <= slave_sda_pad_o when (slave_sda_padoen_oe = '0') else 'Z';
slave_scl_pad_i <= slave_scl;
slave_sda_pad_i <= slave_sda;

slave_sda_padoen_o <= slave_sda_padoen_oe;

wb_adr<=adr when test='0' else tadr_o;
wb_we_i<=we when test='0' else twe;
wb_stb_i<=stb when test='0' else tstb;
wb_cyc_i<=cyc when test='0' else '1';
wb_dat_i<=dat_i when test='0' else tdat_o;
adr_o<=wb_adr;
datint_o<=wb_dat_i;
we_o<=wb_we_i;
stb_o<=wb_stb_i;
dat_o<=wb_dat_o;
scl_padoen_o <= scl_padoen_oe;                   -- i2c clock line output enable, active low            
sda_padoen_o <= sda_padoen_oe;                     -- i2c data line output enable, active low

end Behavioral;

