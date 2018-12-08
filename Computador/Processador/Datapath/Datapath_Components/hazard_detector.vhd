library IEEE; use IEEE.STD_LOGIC_1164.all;

entity hazard_detector is
	port(			   	   
		reset: in std_logic;
		pcsrc: in std_logic;
		jump:  in std_logic;												 	
		op_ID: in std_logic_vector(5 downto 0);
		rs_ID, rt_ID: in std_logic_vector(4 downto 0); 
		writereg_EX: in std_logic_vector(4 downto 0);  
		memtoreg_EX: in std_logic;
		
		enable_PCplus4: out std_logic;
		enable_IF_ID:   out std_logic;
		enable_ID_EX:   out std_logic;
		reset_IF_ID:    out std_logic;
		reset_ID_EX:    out std_logic;
		reset_EX_MEM:	out std_logic;
		reset_MEM_WB:	out std_logic
	);
end hazard_detector;						 
													  
architecture behave of hazard_detector is
	
	constant RTYPE: std_logic_vector(5 downto 0):= "000000";
	constant J:     std_logic_vector(5 downto 0):= "000010";
	constant BEQ:   std_logic_vector(5 downto 0):= "000100";
	constant BNE:   std_logic_vector(5 downto 0):= "000101";
	constant ADDI:  std_logic_vector(5 downto 0):= "001000";
	constant ORI:   std_logic_vector(5 downto 0):= "001101"; 
	constant LW:    std_logic_vector(5 downto 0):= "100011";
	constant SW:    std_logic_vector(5 downto 0):= "101011"; 
													
	signal eq_EX, eq_MEM, hazard_EX, hazard_MEM, hazard: std_logic;
	signal eq_rs_EX, eq_rt_EX, eq_rs_MEM, eq_rt_MEM: std_logic;	
	
begin

	process(all) begin
		
	eq_rs_EX <= '1' when (rs_ID = writereg_EX) else '0'; 	
	eq_rt_EX <= '1' when (rt_ID = writereg_EX) else '0'; 
														   		
	with op_ID select
	eq_EX <= (eq_rs_EX or eq_rt_EX) when RTYPE | BEQ| BNE,
			 (eq_rs_EX) when ADDI | ORI | LW, 
	 		 (eq_rt_EX)	when SW,
			 '0' when others;
								  					   	
	with memtoreg_EX select
	hazard <= eq_EX when '1',
	     	  '0' when others; 									  
	
	enable_PCplus4 <= not hazard;
	enable_IF_ID <= not hazard;
	enable_ID_EX <= not hazard;
	
	reset_IF_ID <= reset or pcsrc or jump;
	reset_ID_EX <= reset or pcsrc or hazard;
	reset_EX_MEM <= reset or pcsrc; 
	reset_MEM_WB <= reset;
	
  end process;

end behave;
