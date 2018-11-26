library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity mips is -- single cycle MIPS processor
  port(clk, reset:        in  STD_LOGIC;
       pc:                out STD_LOGIC_VECTOR(31 downto 0);
       instr:             in  STD_LOGIC_VECTOR(31 downto 0);
       memwrite:          out STD_LOGIC;
       aluout, writedata: out STD_LOGIC_VECTOR(31 downto 0);
       readdata:          in  STD_LOGIC_VECTOR(31 downto 0));
end mips;

architecture struct of mips is
  component controller
    port(op, funct:          	 in  STD_LOGIC_VECTOR(5 downto 0);
         memtoreg, memwrite: 	 out STD_LOGIC;
	     branch, Nbranch: 		 out STD_LOGIC;
         extSign, alusrc:        out STD_LOGIC;
         regdst, regwrite:   	 out STD_LOGIC;
         jump:               	 out STD_LOGIC;
         alucontrol:         	 out STD_LOGIC_VECTOR(2 downto 0));
  end component;
  component datapath
    port(clk, reset:        	  in  STD_LOGIC;
		 memtoreg, memwrite:   	  in  STD_LOGIC;
		 branch, Nbranch:         in  STD_LOGIC;
         extSign, alusrc, regdst: in  STD_LOGIC;
         regwrite, jump:    	  in  STD_LOGIC;
         alucontrol:        	  in  STD_LOGIC_VECTOR(2 downto 0);
         zero:              	  out STD_LOGIC;
         pc:                	  buffer STD_LOGIC_VECTOR(31 downto 0);
         instr:             	  in STD_LOGIC_VECTOR(31 downto 0);
		 instr_ID:                buffer  STD_LOGIC_VECTOR(31 downto 0);
         aluout, writedata: 	  buffer STD_LOGIC_VECTOR(31 downto 0);
		 memwrite_MEM:            out std_logic;
         readdata:          	  in  STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal memtoreg, s_memwrite, extSign, alusrc, regdst, regwrite, jump, branch, Nbranch: STD_LOGIC;
  signal zero: STD_LOGIC;
  signal alucontrol: STD_LOGIC_VECTOR(2 downto 0);
  signal s_instr: STD_LOGIC_VECTOR(31 downto 0);
  
begin
  cont: controller port map(s_instr(31 downto 26), s_instr(5 downto 0),
                            memtoreg, s_memwrite, branch, Nbranch, extSign, alusrc,
                            regdst, regwrite, jump, alucontrol);
  dp: datapath port map(clk, reset, memtoreg, s_memwrite, branch, Nbranch, extSign, alusrc, regdst,
                        regwrite, jump, alucontrol, zero, pc, instr, s_instr,
                        aluout, writedata, memwrite, readdata);
end;
