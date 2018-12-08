library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity regPipeline_ID_EX is
	port( 
		-- Signals Register
		clk: in std_logic;
		reg_enable: in std_logic; 
		reg_reset: in std_logic;
		-- Signals Datapath
		in_pc4:             in STD_LOGIC_VECTOR(31 downto 0);
		in_rd1, in_rd2:   	in STD_LOGIC_VECTOR(31 downto 0);
		in_intr31_26:  		in STD_LOGIC_VECTOR(5 downto 0);
		in_intr25_21:  		in STD_LOGIC_VECTOR(4 downto 0);
		in_intr20_16:  		in STD_LOGIC_VECTOR(4 downto 0);
		in_intr15_11:  		in STD_LOGIC_VECTOR(4 downto 0);
		in_signimm:     	in STD_LOGIC_VECTOR(31 downto 0); 	  
		out_pc4: 			out STD_LOGIC_VECTOR(31 downto 0);
		out_rd1, out_rd2:   out STD_LOGIC_VECTOR(31 downto 0);
		out_intr31_26:  	out STD_LOGIC_VECTOR(5 downto 0);
		out_intr25_21:  	out STD_LOGIC_VECTOR(4 downto 0);
		out_intr20_16:  	out STD_LOGIC_VECTOR(4 downto 0);
		out_intr15_11:  	out STD_LOGIC_VECTOR(4 downto 0);
		out_signimm:     	out STD_LOGIC_VECTOR(31 downto 0);
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
		out_Nbranch: out std_logic;
			-- Control EX
		in_regdest: in std_logic;
		in_alusrc: in std_logic;
		in_alucontrol: in STD_LOGIC_VECTOR(2 downto 0);
		out_regdest: out std_logic;
		out_alusrc: out std_logic;
		out_alucontrol: out STD_LOGIC_VECTOR(2 downto 0)	
	);
end regPipeline_ID_EX;

--}} End of automatically maintained section

architecture behave of regPipeline_ID_EX is
begin
	process(all) begin
		if rising_edge(clk) then
			if reg_reset then
			-- Datapath
			out_pc4       <= "--------------------------------";
			out_rd1       <= "--------------------------------";
			out_rd2       <= "--------------------------------";
			out_intr31_26 <= "------";
			out_intr25_21 <= "-----";
			out_intr20_16 <= "-----";
			out_intr15_11 <= "-----";
			out_signimm   <= "--------------------------------";
			-- Controller
			out_regwrite   <= '-';
			out_memtoreg   <= '-'; 
			out_memwrite   <= '-';
			out_branch     <= '-';
			out_Nbranch    <= '-';
			out_regdest    <= '-';
			out_alusrc     <= '-';
			out_alucontrol <= "---";
    	--elsif rising_edge(clk) then
       		elsif reg_enable then
				-- Datapath
				out_pc4       <= in_pc4;
				out_rd1       <= in_rd1;
				out_rd2       <= in_rd2; 	 
				out_intr31_26 <= in_intr31_26;
				out_intr25_21 <= in_intr25_21;
				out_intr20_16 <= in_intr20_16;
				out_intr15_11 <= in_intr15_11;
				out_signimm   <= in_signimm;
				-- Controller
				out_regwrite   <= in_regwrite;
				out_memtoreg   <= in_memtoreg; 
				out_memwrite   <= in_memwrite;
				out_branch     <= in_branch;
				out_Nbranch    <= in_Nbranch;
				out_regdest    <= in_regdest;
				out_alusrc     <= in_alusrc;
				out_alucontrol <= in_alucontrol;
       		end if;
    	end if;
  	end process;

end behave;
