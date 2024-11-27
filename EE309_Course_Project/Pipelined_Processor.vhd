library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pipelined_Processor is
port (clk1 : in std_logic; output0 : out std_logic_vector(15 downto 0); output1 : out std_logic_vector(15 downto 0);
output2 : out std_logic_vector(15 downto 0);output3 : out std_logic_vector(15 downto 0);output4 : out std_logic_vector(15 downto 0);
output5 : out std_logic_vector(15 downto 0);output6 : out std_logic_vector(15 downto 0);output7 : out std_logic_vector(15 downto 0));
end entity;

architecture Pipelined of Pipelined_Processor is

signal IF_ID_PC: std_logic_vector(15 downto 0) := "0000000000000000";
signal IF_ID_IR, IF_PC,ID_RR_PC, ID_RR_IMM6, ID_RR_IMM9, ID_RR_IR, RR_EX_IR, EX_MEM_IR, MEM_WB_IR,WB_OUT_IR,RR_EX_PC,
RR_EX_D1,RR_EX_D2, RR_EX_IMM6, RR_EX_IMM9, EX_MEM_IMM9, EX_MEM_ALUC, MEM_WB_IMM9, MEM_WB_ALUC,
MEM_WB_Dout,WB_OUT_Dout,EX_D1_0,EX_D2_0, EX_MEM_D1,WB_OUT_ALUC,WB_OUT_IMM9: std_logic_vector(15 downto 0);


signal ID_RR_RA, ID_RR_RB, ID_RR_RC, RR_EX_RA, RR_EX_RB, RR_EX_RC, EX_MEM_RA, EX_MEM_RB,
EX_MEM_RC, MEM_WB_RA, MEM_WB_RB, MEM_WB_RC,WB_OUT_RA,WB_OUT_RB,WB_OUT_RC :std_logic_vector(2 downto 0);

signal ID_RR_CMP, RR_EX_CMP, EX_MEM_WRITE_CTRL, MEM_WB_WRITE_CTRL: std_logic;
signal IF_ID_BRANCH, ID_RR_BRANCH, RR_EX_BRANCH, EX_MEM_BRANCH, MEM_WB_BRANCH: std_logic := '0';

signal ID_RR_CZ, RR_EX_CZ :std_logic_vector(1 downto 0);
signal ZERO_FLAG : std_logic := '0';
signal CARRY_FLAG : std_logic:= '0';
signal CARRY_ADD : std_logic_vector(0 downto 0); -- Best way to convert the type to std_logic_vector from std_logic

type REGISTERFILE is array (0 to 7) of std_logic_vector(15 downto 0);
signal REGISTER_FILE : REGISTERFILE := (others => "0000000000000111");

type INSTMEM is array (0 to 65535) of std_logic_vector(15 downto 0);
signal INST_MEM : INSTMEM := ("0001000001010000","0001000001011001","0011000000001111","0001000000000000","0001000000000000","0101000101000001",others => "0001000001010000");

type DATAMEM is array (0 to 100) of std_logic_vector(15 downto 0); -- Tentatively, taken to be of 100 elements otherwise it was taking huge time for compilation.
signal DATA_MEM : DATAMEM := (others => "0000000000000100");



signal ID_PC, ID_IMM6, ID_IMM9, ID_IR, RR_IR, EX_IR, MEM_IR, WB_IR,RR_PC,
RR_D1,RR_D2, RR_IMM6, RR_IMM9, EX_IMM9, EX_ALUC, MEM_IMM9, WB_IMM9, MEM_ALUC,
MEM_D1, WB_ALUC, WB_Dout: std_logic_vector(15 downto 0);

signal ID_RA, ID_RB, ID_RC, RR_RA, RR_RB, RR_RC, EX_RA, EX_RB,
EX_RC, MEM_RA, MEM_RB, MEM_RC, WB_RA, WB_RB, WB_RC :std_logic_vector(2 downto 0);

signal ID_CMP, RR_CMP, EX_WRITE_CTRL, MEM_WRITE_CTRL, WB_WRITE_CTRL,WB_OUT_WRITE_CTRL : std_logic;
signal ID_BRANCH, RR_BRANCH, EX_BRANCH, MEM_BRANCH, WB_BRANCH: std_logic;

signal ID_CZ, RR_CZ :std_logic_vector(1 downto 0);



begin








Instruction_Fetch:process(clk1) -- Instruction Fetch 
begin
if(clk1='0' and clk1' event) then
IF_ID_IR <= INST_MEM(to_integer(unsigned(IF_ID_PC)));
IF_PC <= IF_ID_PC;

if((RR_EX_IR(15 downto 12)="1000" and RR_EX_D1=RR_EX_D2) or (RR_EX_IR(15 downto 12)="1001" and RR_EX_D1<RR_EX_D2)
 or (RR_EX_IR(15 downto 12)="1011" and (not(RR_EX_D1>RR_EX_D2)))) and RR_EX_BRANCH = '0' then
 
 IF_ID_PC <= std_logic_vector(unsigned(RR_EX_PC) + unsigned(RR_EX_IMM6));
 IF_ID_BRANCH <= '1';

 
 
 elsif(RR_EX_IR(15 downto 12)="1100") and RR_EX_BRANCH = '0' then
 
 IF_ID_PC <= std_logic_vector(unsigned(RR_EX_PC) + unsigned(RR_EX_IMM6));
 IF_ID_BRANCH <= '1';
 
 elsif(RR_EX_IR(15 downto 12)="1101") and RR_EX_BRANCH = '0'then
 
 IF_ID_PC <= RR_EX_D2;
 IF_ID_BRANCH <= '1';
 
 elsif(RR_EX_IR(15 downto 12)="1111") and RR_EX_BRANCH = '0' then
 
 IF_ID_PC <= EX_ALUC;
 IF_ID_BRANCH <= '1';
 
 else
 
 IF_ID_PC <= std_logic_vector(unsigned(IF_ID_PC) + 1);
 IF_ID_BRANCH <= '0';
end if;

end if;

end process Instruction_Fetch;


Instruction_Decode:process(clk1) -- Instruction Decode
begin
if(clk1='1' and clk1' event) then
if (IF_ID_BRANCH = '0') then
ID_PC <= IF_PC;
ID_IR <= IF_ID_IR;


 
ID_RA <= IF_ID_IR(11 downto 9);
ID_RB <= IF_ID_IR(8 downto 6);
ID_RC <= IF_ID_IR(5 downto 3);

if (IF_ID_IR(5)='0') then
ID_IMM6 <= "0000000000"&IF_ID_IR(5 downto 0);
else
ID_IMM6 <= "1111111111"&IF_ID_IR(5 downto 0);
end if;

if (IF_ID_IR(8)='0') then
ID_IMM9 <= "0000000"&IF_ID_IR(8 downto 0);
else
ID_IMM9 <= "1111111"&IF_ID_IR(8 downto 0);
end if;

ID_CMP <= IF_ID_IR(2);
ID_CZ <= IF_ID_IR(1 downto 0);
end if;


if((RR_EX_IR(15 downto 12)="1000" and RR_EX_D1=RR_EX_D2) or (RR_EX_IR(15 downto 12)="1001" and RR_EX_D1<RR_EX_D2)
 or (RR_EX_IR(15 downto 12)="1011" and (not(RR_EX_D1>RR_EX_D2))) or RR_EX_IR(15 downto 12)="1100" or RR_EX_IR(15 downto 12)="1101" or RR_EX_IR(15 downto 12)="1111") and RR_EX_BRANCH = '0' then
 ID_BRANCH <= '1';
 else
 ID_BRANCH <= IF_ID_BRANCH;
 end if;

end if;

end process Instruction_Decode;


Instruction_Decode_Write:process(clk1) -- Instruction Decode
begin
if(clk1='0' and clk1' event) then
if (ID_BRANCH = '0') then
ID_RR_PC <= ID_PC ;
ID_RR_IR <= ID_IR ;


 
ID_RR_RA <= ID_RA;
ID_RR_RB <= ID_RB;
ID_RR_RC <= ID_RC;

ID_RR_IMM6 <= ID_IMM6;
ID_RR_IMM9 <= ID_IMM9;
ID_RR_CMP <= ID_CMP ;
ID_RR_CZ <= ID_CZ ;
end if;
ID_RR_BRANCH <= ID_BRANCH;
end if;
end process Instruction_Decode_Write;












Register_Read:process(clk1) -- Register Read
begin
if(clk1='1' and clk1' event) then
if (ID_RR_BRANCH = '0') then
RR_PC <= ID_RR_PC ;
RR_RA <= ID_RR_RA;
RR_RB <= ID_RR_RB;
RR_RC <= ID_RR_RC;
RR_IMM6 <= ID_RR_IMM6;
RR_IMM9 <= ID_RR_IMM9;
RR_IR <= ID_RR_IR;





RR_CMP <= ID_RR_CMP;
RR_CZ <= ID_RR_CZ;
RR_D1 <= REGISTER_FILE(to_integer(unsigned(ID_RR_RA)));
RR_D2 <= REGISTER_FILE(to_integer(unsigned(ID_RR_RB)));


end if;
if((RR_EX_IR(15 downto 12)="1000" and RR_EX_D1=RR_EX_D2) or (RR_EX_IR(15 downto 12)="1001" and RR_EX_D1<RR_EX_D2)
 or (RR_EX_IR(15 downto 12)="1011" and (not(RR_EX_D1>RR_EX_D2))) or RR_EX_IR(15 downto 12)="1100" or RR_EX_IR(15 downto 12)="1101" or RR_EX_IR(15 downto 12)="1111") and RR_EX_BRANCH = '0' then
 RR_BRANCH <= '1';
 else
 RR_BRANCH <= ID_RR_BRANCH;
 end if;
end if;
end process Register_Read;

Register_Read_Write:process(clk1) -- Register Read_Write
begin
if(clk1='0' and clk1' event) then
if (RR_BRANCH = '0') then
RR_EX_PC <= RR_PC; 
RR_EX_RA <= RR_RA;
RR_EX_RB <= RR_RB;
RR_EX_RC <= RR_RC;
RR_EX_IMM6 <= RR_IMM6;
RR_EX_IMM9 <= RR_IMM9;
RR_EX_IR <= RR_IR;



RR_EX_CMP <= RR_CMP;
RR_EX_CZ <= RR_CZ;
RR_EX_D1 <= RR_D1;
RR_EX_D2 <= RR_D2;

end if;
RR_EX_BRANCH <= RR_BRANCH;
end if;
end process Register_Read_Write;
--
--
--
--
--
--
--
EXECUTION:process(clk1) -- Execution
variable EX_D1,EX_D2,EX_ALUC_V : std_logic_vector(15 downto 0);
begin
if(clk1='1' and clk1' event) then
if (RR_EX_BRANCH = '0') then
EX_RA <= RR_EX_RA;
EX_RB <= RR_EX_RB;
EX_RC <= RR_EX_RC;
EX_IMM9 <= RR_EX_IMM9;

EX_IR <= RR_EX_IR;
EX_D1 := RR_EX_D1;
EX_D2 := RR_EX_D2;
EX_D1_0 <= RR_EX_D1;
EX_D2_0 <= RR_EX_D2;
if (RR_EX_RA = EX_MEM_RC and EX_MEM_WRITE_CTRL = '1' and (EX_MEM_IR(15 downto 12) = "0001" or EX_MEM_IR(15 downto 12) = "0010")) then
EX_D1 := EX_MEM_ALUC;
EX_D1_0 <= EX_MEM_ALUC;
elsif (RR_EX_RB = EX_MEM_RC and EX_MEM_WRITE_CTRL = '1' and (EX_MEM_IR(15 downto 12) = "0001" or EX_MEM_IR(15 downto 12) = "0010")) then
EX_D2 := EX_MEM_ALUC;
EX_D2_0 <= EX_MEM_ALUC;
elsif (RR_EX_RA = EX_MEM_RB and EX_MEM_WRITE_CTRL = '1' and EX_MEM_IR(15 downto 12) = "0000") then
EX_D1 := EX_MEM_ALUC;
EX_D1_0 <= EX_MEM_ALUC;
elsif (RR_EX_RB = EX_MEM_RB and EX_MEM_WRITE_CTRL = '1' and EX_MEM_IR(15 downto 12) = "0000") then
EX_D2 := EX_MEM_ALUC;
EX_D2_0 <= EX_MEM_ALUC;
elsif (RR_EX_RA = EX_MEM_RA and EX_MEM_WRITE_CTRL = '1' and (EX_MEM_IR(15 downto 12) = "1100" or EX_MEM_IR(15 downto 12) = "1101")) then
EX_D1 := EX_MEM_ALUC;
EX_D1_0 <= EX_MEM_ALUC;
elsif (RR_EX_RB = EX_MEM_RA and EX_MEM_WRITE_CTRL = '1' and (EX_MEM_IR(15 downto 12) = "1100" or EX_MEM_IR(15 downto 12) = "1101")) then
EX_D2 := EX_MEM_ALUC;
EX_D2_0 <= EX_MEM_ALUC;


elsif (RR_EX_RA = EX_MEM_RA and EX_MEM_WRITE_CTRL = '1' and (EX_MEM_IR(15 downto 12) = "0011"))then
EX_D1 := EX_MEM_IMM9 and "0000000111111111";
EX_D1_0 <= EX_MEM_IMM9 and "0000000111111111";
elsif (RR_EX_RB = EX_MEM_RA and EX_MEM_WRITE_CTRL = '1' and (EX_MEM_IR(15 downto 12) = "0011")) then
EX_D2 := EX_MEM_IMM9 and "0000000111111111";
EX_D2_0 <= EX_MEM_IMM9 and "0000000111111111";


elsif (RR_EX_RA = MEM_WB_RC and MEM_WB_WRITE_CTRL = '1' and (MEM_WB_IR(15 downto 12) = "0001" or MEM_WB_IR(15 downto 12) = "0010")) then
EX_D1 := MEM_WB_ALUC;
EX_D1_0 <= MEM_WB_ALUC;
elsif (RR_EX_RB = MEM_WB_RC and MEM_WB_WRITE_CTRL = '1' and (MEM_WB_IR(15 downto 12) = "0001" or MEM_WB_IR(15 downto 12) = "0010")) then
EX_D2 := MEM_WB_ALUC;
EX_D2_0 <= MEM_WB_ALUC;
elsif (RR_EX_RA = MEM_WB_RB and MEM_WB_WRITE_CTRL = '1' and MEM_WB_IR(15 downto 12) = "0000") then
EX_D1 := MEM_WB_ALUC;
EX_D1_0 <= MEM_WB_ALUC;
elsif (RR_EX_RB = MEM_WB_RB and MEM_WB_WRITE_CTRL = '1' and MEM_WB_IR(15 downto 12) = "0000") then
EX_D2 := MEM_WB_ALUC;
EX_D2_0 <= MEM_WB_ALUC;
elsif (RR_EX_RA = MEM_WB_RA and MEM_WB_WRITE_CTRL = '1' and (  MEM_WB_IR(15 downto 12) = "1100" or MEM_WB_IR(15 downto 12) = "1101")) then
EX_D1 := MEM_WB_ALUC;
EX_D1_0 <= MEM_WB_ALUC;
elsif (RR_EX_RB = MEM_WB_RA and MEM_WB_WRITE_CTRL = '1' and ( MEM_WB_IR(15 downto 12) = "1100" or MEM_WB_IR(15 downto 12) = "1101")) then
EX_D2 := MEM_WB_ALUC;
EX_D2_0 <= MEM_WB_ALUC;


elsif (RR_EX_RA = MEM_WB_RA and MEM_WB_WRITE_CTRL = '1' and (MEM_WB_IR(15 downto 12) = "0011"))  then
EX_D1 := MEM_WB_IMM9 and "0000000111111111";
EX_D1_0 <= MEM_WB_IMM9 and "0000000111111111";
elsif (RR_EX_RB = MEM_WB_RA and MEM_WB_WRITE_CTRL = '1' and (MEM_WB_IR(15 downto 12) = "0011" )) then
EX_D2 := MEM_WB_IMM9 and "0000000111111111";
EX_D2_0 <= MEM_WB_IMM9 and "0000000111111111";

elsif (RR_EX_RA = MEM_WB_RA and MEM_WB_WRITE_CTRL = '1' and (MEM_WB_IR(15 downto 12) = "0100"))  then
EX_D1 := MEM_WB_Dout;
EX_D1_0 <= MEM_WB_Dout;
elsif (RR_EX_RB = MEM_WB_RA and MEM_WB_WRITE_CTRL = '1' and (MEM_WB_IR(15 downto 12) = "0100" )) then
EX_D2 := MEM_WB_Dout;
EX_D2_0 <= MEM_WB_Dout;

elsif (RR_EX_RA = WB_OUT_RC and WB_OUT_WRITE_CTRL = '1' and (WB_OUT_IR(15 downto 12) = "0001" or WB_OUT_IR(15 downto 12) = "0010")) then
EX_D1 := WB_OUT_ALUC;
EX_D1_0 <= WB_OUT_ALUC;
elsif (RR_EX_RB = WB_OUT_RC and WB_OUT_WRITE_CTRL = '1' and (WB_OUT_IR(15 downto 12) = "0001" or WB_OUT_IR(15 downto 12) = "0010")) then
EX_D2 := WB_OUT_ALUC;
EX_D2_0 <= WB_OUT_ALUC;
elsif (RR_EX_RA = WB_OUT_RB and WB_OUT_WRITE_CTRL = '1' and WB_OUT_IR(15 downto 12) = "0000") then
EX_D1 := WB_OUT_ALUC;
EX_D1_0 <= WB_OUT_ALUC;
elsif (RR_EX_RB = WB_OUT_RB and WB_OUT_WRITE_CTRL = '1' and WB_OUT_IR(15 downto 12) = "0000") then
EX_D2 := WB_OUT_ALUC;
EX_D2_0 <= WB_OUT_ALUC;
elsif (RR_EX_RA = WB_OUT_RA and WB_OUT_WRITE_CTRL = '1' and ( WB_OUT_IR(15 downto 12) = "1100" or WB_OUT_IR(15 downto 12) = "1101")) then
EX_D1 := WB_OUT_ALUC;
EX_D1_0 <= WB_OUT_ALUC;
elsif (RR_EX_RB = WB_OUT_RA and WB_OUT_WRITE_CTRL = '1' and (WB_OUT_IR(15 downto 12) = "1100" or WB_OUT_IR(15 downto 12) = "1101")) then
EX_D2 := WB_OUT_ALUC;
EX_D2_0 <= WB_OUT_ALUC;

elsif (RR_EX_RA = WB_OUT_RA and WB_OUT_WRITE_CTRL = '1' and (WB_OUT_IR(15 downto 12) = "0011")) then
EX_D1 := WB_OUT_IMM9 and "0000000111111111";
EX_D1_0 <= WB_OUT_IMM9 and "0000000111111111";
elsif (RR_EX_RB = WB_OUT_RA and WB_OUT_WRITE_CTRL = '1' and (WB_OUT_IR(15 downto 12) = "0011")) then
EX_D2 := WB_OUT_IMM9 and "0000000111111111";
EX_D2_0 <= WB_OUT_IMM9 and "0000000111111111";

elsif (RR_EX_RA = WB_OUT_RA and WB_OUT_WRITE_CTRL = '1' and (WB_OUT_IR(15 downto 12) = "0100")) then
EX_D1 := WB_OUT_Dout;
EX_D1_0 <= WB_OUT_Dout;
elsif (RR_EX_RB = WB_OUT_RA and WB_OUT_WRITE_CTRL = '1' and (WB_OUT_IR(15 downto 12) = "0100")) then
EX_D2 := WB_OUT_Dout;
EX_D2_0 <= WB_OUT_Dout;

else
EX_D1 := RR_EX_D1;
EX_D2 := RR_EX_D2;
EX_D1_0 <= RR_EX_D1;
EX_D2_0 <= RR_EX_D2;
end if;

if(RR_EX_RA = RR_EX_RB) then -- to tackle Rn, Rm, Rm condition
EX_D2 := EX_D1;
EX_D2_0 <= EX_D1;
end if;

case RR_EX_IR(15 downto 12) is

when "0001" => -- ALL ADD INSTRUCTIONS EXCEPT ADI
if (RR_EX_CMP = '1') then
EX_D2 := not(EX_D2);
end if;

if RR_EX_CZ = "00" or RR_EX_CZ = "01" or RR_EX_CZ =  "10" then

if (RR_EX_CZ = "00") then
EX_WRITE_CTRL <= '1';
elsif (RR_EX_CZ = "10") then
if (CARRY_FLAG = '1') then
EX_WRITE_CTRL <= '1';
else
EX_WRITE_CTRL <= '0';
end if;
elsif (RR_EX_CZ = "01") then
if (ZERO_FLAG = '1') then
EX_WRITE_CTRL <= '1';
else
EX_WRITE_CTRL <= '0';
end if;
end if;

EX_ALUC <= std_logic_vector(unsigned(EX_D1) + unsigned(EX_D2));
EX_ALUC_V := std_logic_vector(unsigned(EX_D1) + unsigned(EX_D2));
if (unsigned(EX_ALUC_V) = 0) then 
ZERO_FLAG <= '1';
else
ZERO_FLAG <= '0';
end if;

if (unsigned(EX_D1) + unsigned(EX_D2))> 65535 then
CARRY_FLAG <= '1';
else
CARRY_FLAG <= '0';
end if;
else

EX_WRITE_CTRL <= '1';
CARRY_ADD(0) <= CARRY_FLAG; -- Best way to convert the type to std_logic_vector from std_logic
EX_ALUC <= std_logic_vector(unsigned(EX_D1) + unsigned(EX_D2)+(unsigned(CARRY_ADD)));
EX_ALUC_V := std_logic_vector(unsigned(EX_D1) + unsigned(EX_D2)+(unsigned(CARRY_ADD)));
if (unsigned(EX_ALUC_V) = 0) then 
ZERO_FLAG <= '1';
else
ZERO_FLAG <= '0';
end if;

if (unsigned(EX_D1) + unsigned(EX_D2))> 65535 then
CARRY_FLAG <= '1';
else
CARRY_FLAG <= '0';
end if;
end if;


when "0000" => -- ADI

EX_WRITE_CTRL <= '1';
EX_ALUC <= std_logic_vector(unsigned(EX_D1) + unsigned(RR_EX_IMM6));
EX_ALUC_V := std_logic_vector(unsigned(EX_D1) + unsigned(RR_EX_IMM6));

if (unsigned(EX_ALUC_V) = 0) then  
ZERO_FLAG <= '1';
else
ZERO_FLAG <= '0';
end if;

if (unsigned(EX_D1) + unsigned(EX_D2))> 65535 then
CARRY_FLAG <= '1';
else
CARRY_FLAG <= '0';
end if;


when "0010" => -- ALL NAND INSTRUCTIONS
if (RR_EX_CMP = '1') then
EX_D2 := not(EX_D2);
end if;

if (RR_EX_CZ = "00") then
EX_WRITE_CTRL <= '1';
elsif (RR_EX_CZ = "10") then
if (CARRY_FLAG = '1') then
EX_WRITE_CTRL <= '1';
else
EX_WRITE_CTRL <= '0';
end if;
elsif (RR_EX_CZ = "01") then
if (ZERO_FLAG = '1') then
EX_WRITE_CTRL <= '1';
else
EX_WRITE_CTRL <= '0';
end if;
end if;

EX_ALUC <= EX_D1 nand EX_D2;
EX_ALUC_V := EX_D1 nand EX_D2;

if (unsigned(EX_ALUC_V) = 0) then 
ZERO_FLAG <= '1';
else
ZERO_FLAG <= '0';
end if;

when "0011" => -- LLI
EX_WRITE_CTRL <= '1';

when "0100" | "0101" => --LW sw
EX_WRITE_CTRL <= not(RR_EX_IR(12));
EX_ALUC <= std_logic_vector(unsigned(EX_D2) + unsigned(RR_EX_IMM6));

when "1100" | "1101" => -- JAL JLR
EX_WRITE_CTRL <= '1';
EX_ALUC <= std_logic_vector(unsigned(RR_EX_PC) + 1);

when "1111" => --JRI
EX_ALUC <= std_logic_vector(unsigned(EX_D1) + unsigned(RR_EX_IMM9));

when others => 
	null;
end case;


end if;
EX_BRANCH <= RR_EX_BRANCH;
end if;
end process EXECUTION;

EXECUTION_WRITE:process(clk1) -- Execution_Write
begin
if(clk1='0' and clk1' event) then
if (EX_BRANCH = '0') then
EX_MEM_RA <= EX_RA;
EX_MEM_RB <= EX_RB;
EX_MEM_RC <= EX_RC;
EX_MEM_IMM9 <= EX_IMM9;

EX_MEM_IR <= EX_IR;


EX_MEM_D1 <= EX_D1_0;
EX_MEM_WRITE_CTRL <= EX_WRITE_CTRL;
EX_MEM_ALUC <= EX_ALUC;

end if;
EX_MEM_BRANCH <= EX_BRANCH;
end if;
end process EXECUTION_WRITE;


Memory_Access:process(clk1) -- Memory Access
begin
if(clk1='1' and clk1' event) then
if (EX_MEM_BRANCH = '0') then
MEM_RA <= EX_MEM_RA;
MEM_RB <= EX_MEM_RB;
MEM_RC <= EX_MEM_RC;
MEM_IMM9 <= EX_MEM_IMM9;
MEM_ALUC <= EX_MEM_ALUC;

MEM_WRITE_CTRL <= EX_MEM_WRITE_CTRL;
MEM_IR <= EX_MEM_IR;
MEM_D1 <= EX_MEM_D1;


end if;
MEM_BRANCH <= EX_MEM_BRANCH;
end if;
end process Memory_Access;

Memory_Access_Write:process(clk1) -- Memory Access Write
begin
if(clk1='0' and clk1' event) then
if (MEM_BRANCH = '0') then
MEM_WB_RA <= MEM_RA;            
MEM_WB_RB <= MEM_RB;            
MEM_WB_RC <= MEM_RC;            
MEM_WB_IMM9 <= MEM_IMM9;           
MEM_WB_ALUC <= MEM_ALUC;            
          
MEM_WB_WRITE_CTRL <= MEM_WRITE_CTRL;          
MEM_WB_IR <= MEM_IR;            

if (MEM_IR(15 downto 12) = "0100") then
MEM_WB_Dout <= DATA_MEM(to_integer(unsigned(MEM_ALUC)));
end if;
if (MEM_IR(15 downto 12) = "0101") then
DATA_MEM(to_integer(unsigned(MEM_ALUC))) <= MEM_D1;
end if;
end if;
MEM_WB_BRANCH <= MEM_BRANCH;  
end if;
end process Memory_Access_Write;



Write_Back:process(clk1) -- Write Back
begin
if(clk1='1' and clk1' event) then
if (MEM_WB_BRANCH = '0') then
if (MEM_WB_WRITE_CTRL = '1') then

WB_RA <= MEM_WB_RA;            
WB_RB <= MEM_WB_RB;            
WB_RC <= MEM_WB_RC;            
WB_IMM9 <= MEM_WB_IMM9;           
WB_ALUC <= MEM_WB_ALUC;            
           
WB_WRITE_CTRL <= MEM_WB_WRITE_CTRL;          
WB_IR <= MEM_WB_IR;            
WB_Dout <= MEM_WB_Dout;


end if;
end if;
WB_BRANCH <= MEM_WB_BRANCH; 
end if;

-- output <= MEM_WB_ALUC;
end process Write_Back;




Write_Back_Write:process(clk1) -- Write Back Write
begin
if(clk1='0' and clk1' event) then
if (WB_BRANCH = '0') then
WB_OUT_RA <= WB_RA;
WB_OUT_RB <= WB_RB;
WB_OUT_RC <= WB_RC;
WB_OUT_IMM9 <= WB_IMM9;
WB_OUT_ALUC <= WB_ALUC;
WB_OUT_WRITE_CTRL <= WB_WRITE_CTRL;
WB_OUT_IR <= WB_IR;
WB_OUT_Dout <= WB_Dout;
if (WB_WRITE_CTRL = '1') then

case WB_IR(15 downto 12) is
when "0001" | "0010" =>

REGISTER_FILE(to_integer(unsigned(WB_RC))) <= WB_ALUC;

when "0000" =>

REGISTER_FILE(to_integer(unsigned(WB_RB))) <= WB_ALUC;

when "0011" =>

REGISTER_FILE(to_integer(unsigned(WB_RA))) <= WB_IMM9 and "0000000111111111";

when "0100" =>

REGISTER_FILE(to_integer(unsigned(WB_RA))) <= WB_Dout;

when "1100" | "1101" =>

REGISTER_FILE(to_integer(unsigned(WB_RA))) <= WB_ALUC;

when others =>
null;
end case;

end if;
end if;

end if;

end process Write_Back_Write;
output0 <= REGISTER_FILE(0);
output1 <= REGISTER_FILE(1);
output2 <= REGISTER_FILE(2);
output3 <= REGISTER_FILE(3);
output4 <= REGISTER_FILE(4);
output5 <= WB_ALUC;
output6(7) <= MEM_WB_WRITE_CTRL; 
output6(6) <= WB_WRITE_CTRL; 

output7 <= DATA_MEM(8);
end Pipelined;