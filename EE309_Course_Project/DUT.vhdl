-- A DUT entity is used to wrap your design so that we can combine it with testbench.
-- This example shows how you can do this for the OR Gate

library ieee;
use ieee.std_logic_1164.all;

entity DUT is
    port(input_vector: in std_logic_vector(3z downto 0);
       	output_vector: out std_logic_vector(0 downto 0));
end entity;

architecture DutWrap of DUT is
   component PD is
     port(x3,x2,x1,x0: in std_logic;
         y: out std_logic);
   end component;
begin

   -- input/output vector element ordering is critical,
   -- and must match the ordering in the trace file!
   add_instance: PD 
			port map (
					-- order of inputs B A
					x3 => input_vector(3),
					x2 => input_vector(2),
					x1 => input_vector(1),
					x0 => input_vector(0),
               -- order of output OUTPUT
					y => output_vector(0));
end DutWrap;