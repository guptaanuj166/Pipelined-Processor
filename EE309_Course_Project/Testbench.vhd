LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
entity Testbench is
end entity Testbench;

architecture bhv of Testbench is
component Pipelined_Processor is
port (clk1 : in std_logic; output0 : out std_logic_vector(15 downto 0); output1 : out std_logic_vector(15 downto 0);
output2 : out std_logic_vector(15 downto 0);output3 : out std_logic_vector(15 downto 0);output4 : out std_logic_vector(15 downto 0);
output5 : out std_logic_vector(15 downto 0);output6 : out std_logic_vector(15 downto 0);output7 : out std_logic_vector(15 downto 0));
end component Pipelined_Processor;


signal clk1: std_logic := '1';
signal output0:std_logic_vector(15 downto 0);
signal output1:std_logic_vector(15 downto 0);
signal output2:std_logic_vector(15 downto 0);
signal output3:std_logic_vector(15 downto 0);
signal output4:std_logic_vector(15 downto 0);
signal output5:std_logic_vector(15 downto 0);
signal output6:std_logic_vector(15 downto 0);
signal output7:std_logic_vector(15 downto 0);
begin

	
dut_instance: Pipelined_Processor port map(clk1,output0,output1,output2,output3,output4,output5,output6,output7);
clk1 <= not clk1 after 10 ms ;
end bhv;
	

