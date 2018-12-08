library IEEE; use IEEE.STD_LOGIC_1164.all; use IEEE.STD_LOGIC_ARITH.all;

entity fowarding_unit is
	port(
	op_EX: 		  in std_logic_vector(5 downto 0);
	rs_EX: 		  in STD_LOGIC_VECTOR(4 downto 0);
	rt_EX: 		  in STD_LOGIC_VECTOR(4 downto 0);
	writereg_MEM: in STD_LOGIC_VECTOR(4 downto 0);
	writereg_WB:  in STD_LOGIC_VECTOR(4 downto 0);
	regWrite_MEM: in std_logic;		
	regWrite_WB:  in std_logic;						 
	selSrca:	  out std_logic_vector(1 downto 0);
	selSrcB:	  out std_logic_vector(1 downto 0)
	);
end fowarding_unit;
											 
architecture behave of fowarding_unit is


	constant RTYPE: std_logic_vector(5 downto 0):= "000000";
	constant J:     std_logic_vector(5 downto 0):= "000010";
	constant BEQ:   std_logic_vector(5 downto 0):= "000100";
	constant BNE:   std_logic_vector(5 downto 0):= "000101";
	constant ADDI:  std_logic_vector(5 downto 0):= "001000";
	constant ORI:   std_logic_vector(5 downto 0):= "001101"; 
	constant LW:    std_logic_vector(5 downto 0):= "100011";
	constant SW:    std_logic_vector(5 downto 0):= "101011"; 
	
	signal eq_WB, eq_MEM: std_logic;
	signal eq_rs_WB, eq_rt_WB, eq_rs_MEM, eq_rt_MEM: std_logic;
	signal rs_used, rt_used:  std_logic;
	
begin	
	
	process(all) begin
		
	eq_rs_WB <= '1' when (rs_EX = writereg_WB) else '0'; 	
	eq_rt_WB <= '1' when (rt_EX = writereg_WB) else '0'; 
	
	eq_rs_MEM <= '1' when (rs_EX = writereg_MEM) else '0'; 	
	eq_rt_MEM <= '1' when (rt_EX = writereg_MEM) else '0'; 
	
	with op_EX select
	rs_used <= '1' when RTYPE | BEQ| BNE | ADDI | ORI | LW | SW,
			   '0' when others;
	
	with op_EX select
	rt_used <= '1' when RTYPE | BEQ| BNE | LW | SW,
			   '0' when others;
		
	--src(a/b) when "00",
	--result   when "01",
	--alout    when others;
			  	  
	selSrca <= 	rs_used and((eq_rs_MEM and regwrite_MEM)&(eq_rs_WB and regwrite_WB));
	selSrcb <= 	rt_used and((eq_rt_MEM and regwrite_MEM)&(eq_rt_WB and regwrite_WB));					  

  	end process;
	
end behave;