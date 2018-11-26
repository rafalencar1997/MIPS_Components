library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity regPipeline_MEM_WB is
	generic(width: integer);
	port(
		-- Signals Register
		clk: in std_logic;
		reg_enable:  in std_logic;
		reg_reset: in std_logic;
		-- Signals Datapath
		in_aluout:	 in STD_LOGIC_VECTOR(31 downto 0);
		in_readdata: in  STD_LOGIC_VECTOR(31 downto 0); 
		in_writereg: in STD_LOGIC_VECTOR(width-1 downto 0);
		out_aluout:	 out STD_LOGIC_VECTOR(31 downto 0);
		out_readdata: out  STD_LOGIC_VECTOR(31 downto 0); 
		out_writereg: out STD_LOGIC_VECTOR(width-1 downto 0);
		-- Signals Controller
			-- Control WB
		in_regwrite: in std_logic;
		in_memtoreg: in std_logic;	  
		out_regwrite: out std_logic;
		out_memtoreg: out std_logic
		
	);	
end regPipeline_MEM_WB;

--}} End of automatically maintained section

architecture behave of regPipeline_MEM_WB is
begin
	process(all) begin
		if rising_edge(clk) then
			if reg_reset then
			-- Datapath
			out_aluout    <= "--------------------------------";
			out_readdata  <= "--------------------------------"; 
			out_writereg  <= "-----";
			-- Controller
			out_regwrite  <= '-';
			out_memtoreg  <= '-';
    	--elsif rising_edge(clk) then
       		elsif reg_enable then  
				-- Datapath
				out_aluout    <= in_aluout;
				out_readdata  <= in_readdata; 
				out_writereg  <= in_writereg;
				-- Controller
				out_regwrite  <= in_regwrite;
				out_memtoreg  <= in_memtoreg;
       		end if;
    	end if;
  	end process;

end behave;
