library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity regPipeline_EX_MEM is
	generic(width: integer);
	port( 
		-- Signals Register
		clk:	in std_logic;
		reg_enable:   in std_logic;
		reg_reset: in std_logic;
		-- Signals Datapath
		in_zero:	  in std_logic;
		in_aluout:    in STD_LOGIC_VECTOR(31 downto 0);
		in_rd2:       in STD_LOGIC_VECTOR(31 downto 0);
		in_pcbranch:  in STD_LOGIC_VECTOR(31 downto 0);	 
		in_writereg:  in STD_LOGIC_VECTOR(width-1 downto 0);
		out_zero:	  out std_logic;
		out_aluout:   out STD_LOGIC_VECTOR(31 downto 0);
		out_rd2:      out STD_LOGIC_VECTOR(31 downto 0);
		out_pcbranch: out STD_LOGIC_VECTOR(31 downto 0);
		out_writereg: out STD_LOGIC_VECTOR(width-1 downto 0);
		-- Signals Controller
			-- Control WB
		in_regwrite: in std_logic;
		in_memtoreg: in std_logic;	  
		out_regwrite: out std_logic;
		out_memtoreg: out std_logic;
			-- Control MEM
		in_memwrite: in std_logic;
		in_branch: in std_logic;
		in_Nbranch: in std_logic;
		out_memwrite: out std_logic;
		out_branch: out std_logic;
		out_Nbranch: out std_logic
	);	
end regPipeline_EX_MEM;

--}} End of automatically maintained section

architecture behave of regPipeline_EX_MEM is
begin
	process(all) begin
		if rising_edge(clk) then
			if reg_reset then
			-- Datapath
				out_zero		<= '-';
				out_aluout		<= "--------------------------------";
				out_rd2			<= "--------------------------------";
				out_pcbranch	<= "--------------------------------";
				out_writereg	<= "-----";
				-- Controller
				out_regwrite <= '-';
				out_memtoreg <= '-'; 
				out_memwrite <= '-';
				out_branch   <= '-';
				out_Nbranch  <= '-';
    	--elsif rising_edge(clk) then
       		elsif reg_enable then 
				-- Datapath
				out_zero		<= in_zero;
				out_aluout		<= in_aluout;
				out_rd2			<= in_rd2;
				out_pcbranch	<= in_pcbranch;
				out_writereg	<= in_writereg;
				-- Controller
				out_regwrite <= in_regwrite;
				out_memtoreg <= in_memtoreg; 
				out_memwrite <= in_memwrite;
				out_branch   <= in_branch;
				out_Nbranch  <= in_Nbranch;		
       		end if;
    	end if;
  	end process;

end behave;
