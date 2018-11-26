library IEEE;
use IEEE.std_logic_1164.all;

entity regPipeline_IF_ID is
	port(
		-- Signals Register
		clk:        in STD_LOGIC;
		reg_enable: in STD_LOGIC;
		reg_reset:  in std_logic; 
		-- Signals Datapath
		in_instr:   in STD_LOGIC_VECTOR(31 downto 0);
		in_pc4:     in STD_LOGIC_VECTOR(31 downto 0);
		out_instr:  out STD_LOGIC_VECTOR(31 downto 0);
		out_pc4:    out STD_LOGIC_VECTOR(31 downto 0)
	 );
end regPipeline_IF_ID;

--}} End of automatically maintained section

architecture behave of regPipeline_IF_ID is
begin
	process(all) begin			
		if rising_edge(clk) then
			if reg_reset then
			out_instr <= "--------------------------------";
			out_pc4 <= "--------------------------------";	
    	--elsif rising_edge(clk) then
       		elsif reg_enable then
				out_instr <= in_instr;
				out_pc4 <= in_pc4;
       		end if;
    	end if;
  	end process;					  

end behave;
