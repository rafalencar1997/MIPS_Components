library IEEE; use IEEE.STD_LOGIC_1164.all; use IEEE.STD_LOGIC_ARITH.all;

entity datapath is  -- MIPS datapath
  port(clk, reset:        		in  STD_LOGIC;
  	   memtoreg, memwrite: 		in  STD_LOGIC;
	   branch, Nbranch: 		in  STD_LOGIC;
       extSign, alusrc, regdst: in  STD_LOGIC;
       regwrite, jump:    		in  STD_LOGIC;
       alucontrol:        		in  STD_LOGIC_VECTOR(2 downto 0);
       zero:              		out STD_LOGIC;
       pc:                		buffer STD_LOGIC_VECTOR(31 downto 0);
       instr:             		in  STD_LOGIC_VECTOR(31 downto 0);
	   instr_ID:                buffer  STD_LOGIC_VECTOR(31 downto 0);
       aluout, writedata: 		buffer STD_LOGIC_VECTOR(31 downto 0);
       memwrite_MEM:            out std_logic;
	   readdata:          		in  STD_LOGIC_VECTOR(31 downto 0));
end;

architecture struct of datapath is
  -- Components
  component alu
    port(a, b:       in  STD_LOGIC_VECTOR(31 downto 0);
         alucontrol: in  STD_LOGIC_VECTOR(2 downto 0);
         result:     buffer STD_LOGIC_VECTOR(31 downto 0);
         zero:       out STD_LOGIC);
  end component;
  component regfile
    port(clk:           in  STD_LOGIC;
         we3:           in  STD_LOGIC;
         ra1, ra2, wa3: in  STD_LOGIC_VECTOR(4 downto 0);
         wd3:           in  STD_LOGIC_VECTOR(31 downto 0);
         rd1, rd2:      out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component adder
    port(a, b: in  STD_LOGIC_VECTOR(31 downto 0);
         y:    out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component sl2
    port(a: in  STD_LOGIC_VECTOR(31 downto 0);
         y: out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component signext
    port(extSign: in STD_LOGIC;
		 a:      in  STD_LOGIC_VECTOR(15 downto 0); 	  
         y:      out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component flopr generic(width: integer);
    port(clk, reset, enable: in  STD_LOGIC;
         d:          in  STD_LOGIC_VECTOR(width-1 downto 0);
         q:          out STD_LOGIC_VECTOR(width-1 downto 0));
  end component;
  component mux2 generic(width: integer);
    port(d0, d1: in  STD_LOGIC_VECTOR(width-1 downto 0);
         s:      in  STD_LOGIC;
         y:      out STD_LOGIC_VECTOR(width-1 downto 0));
  end component; 
  
  component regPipeline_IF_ID
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
  end component;
  
  component regPipeline_ID_EX
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
  end component;
  
  component regPipeline_EX_MEM generic(width: integer);
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
  end component;
  
  component regPipeline_MEM_WB generic(width: integer);
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
  end component;
  
  component fowarding_unit
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
  end component;
  
  component hazard_detector
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
  end component;
  
  -- Signals
  signal zero_EX,
   		 enable_PCplus4, enable_IF_ID, enable_ID_EX,
  		 reset_IF_ID, reset_ID_EX, reset_EX_MEM, reset_MEM_WB,
  		 pcsrc,
  		 regwrite_EX, regwrite_MEM, regwrite_WB, 
		 memtoreg_EX, memtoreg_MEM, memtoreg_WB,	
  		 memwrite_EX,
		 branch_EX,   branch_MEM,
		 Nbranch_EX,  Nbranch_MEM,
  		 regdst_EX,   alusrc_EX : std_logic;
	
  signal selSrca, selSrcb: STD_LOGIC_VECTOR(1 downto 0);

  signal alucontrol_EX: STD_LOGIC_VECTOR(2 downto 0);
  
  signal writereg_EX, writereg_MEM, writereg_WB,  
  		 rs_EX, rt_EX, rd_EX: STD_LOGIC_VECTOR(4 downto 0);
  
  signal op_EX: STD_LOGIC_VECTOR(5 downto 0);
	
  signal pcjump, pcnext, 
  		 pcnextbr, 
   		 pcplus4, pcplus4_ID, pcplus4_EX,  
         pcbranch, pcbranch_MEM,
		 signimm, signimm_EX,
		 signimmsh,
         srca_ID, srca_EX, srca_ALU,
		 srcb_ALU, result,
		 writedata_ID, writedata_EX, writedata_MUX,
		 aluout_EX, aluout_WB,
		 readdata_WB: STD_LOGIC_VECTOR(31 downto 0);
		 												
		 
  begin
  -- next PC logic
  pcjump <= pcplus4(31 downto 28) & instr_ID(25 downto 0) & "00";
  
  pcreg: flopr generic map(32) 
  port map(clk, reset, enable_PCplus4, pcnext, pc);
  
  pcadd1: adder 
  port map(pc, X"00000004", pcplus4);
  
  immsh: sl2 
  port map(signimm_EX, signimmsh);
  
  pcadd2: adder 
  port map(pcplus4_EX, signimmsh, pcbranch);	 
  
  -- pcbrmux
  pcbrmux: mux2 generic map(32) 
  port map(pcplus4, pcbranch_MEM, pcsrc, pcnextbr);
   
  -- pcmux
  pcmux: mux2 generic map(32) 
  port map(pcnextbr, pcjump, jump, pcnext);  
  
  -- register file logic
  rf: regfile 
  port map(clk, regwrite_WB, instr_ID(25 downto 21), 
  		   instr_ID(20 downto 16), writereg_WB, 
  		   result, srca_ID, writedata_ID);
						                                       		 
  -- wrmux
  wrmux: mux2 generic map(5) 
  port map(rt_EX, rd_EX, regdst_EX, writereg_EX); 
									                           	 
  -- resmux
  resmux: mux2 generic map(32) 
  port map(aluout_WB, readdata_WB, memtoreg_WB, result);
										  
  se: signext 
  port map(extSign, instr_ID(15 downto 0), signimm);
  
  pcsrc <= ((not branch_MEM) and Nbranch_MEM and (not zero)) or 
  		    (branch_MEM and (not Nbranch_MEM) and zero);
  
  -- Pipeline Logic
  IF_ID: regPipeline_IF_ID
	 port map(
	 	clk,
		enable_IF_ID,
		reset_IF_ID,
		instr,
		pcplus4,
		instr_ID,
		pcplus4_ID
	 );			  
  
  ID_EX: regPipeline_ID_EX
  	port map(
  	 	-- Register
  		clk,
		enable_ID_EX,
		reset_ID_EX,
		-- Datapath
		pcplus4_ID,
		srca_ID, 
		writedata_ID,		   
		instr_ID(31 downto 26),
		instr_ID(25 downto 21),
		instr_ID(20 downto 16),
		instr_ID(15 downto 11),
		signimm, 	  
		pcplus4_EX,
		srca_EX, 
		writedata_EX,
		op_EX,
		rs_EX,
		rt_EX,
		rd_EX,
		signimm_EX,
		-- Controller
			-- Control WB
		regwrite,
		memtoreg,	  
		regwrite_EX,
		memtoreg_EX,
			-- Control MEM
		memwrite,
		branch,
		Nbranch,
		memwrite_EX,
		branch_EX,
		Nbranch_EX,
			-- Control EX
		regdst,
		alusrc,
		alucontrol,
		regdst_EX,
		alusrc_EX,
		alucontrol_EX
	 );		  
  
  EX_MEM: regPipeline_EX_MEM generic map (5)
  	port map(
  		-- Register
		clk,
		'1',
		reset_EX_MEM,
		-- Datapath
		zero_EX,
		aluout_EX,
		writedata_MUX,
		pcbranch, 
		writereg_EX,
		zero,
		aluout,
		writedata,
		pcbranch_MEM,
		writereg_MEM,
		-- Controller						
			-- Control WB
		regwrite_EX,
		memtoreg_EX,	  
		regwrite_MEM,
		memtoreg_MEM,
			-- Control MEM
		memwrite_EX,
		branch_EX,
		Nbranch_EX,
		memwrite_MEM,
		branch_MEM,
		Nbranch_MEM
	  );	
  
  MEM_WB: regPipeline_MEM_WB generic map (5)
  	port map(
		-- Register 
		clk,
		'1',
		reset or reset_MEM_WB,	   
		-- Datapath
		aluout,
		readdata,
		writereg_MEM,
		aluout_WB,
		readdata_WB, 
		writereg_WB,
		-- Controller
			-- Control WB
		regwrite_MEM,
		memtoreg_MEM,	  
		regwrite_WB,
		memtoreg_WB	
	);

  FOW: fowarding_unit
  	port map(
		op_EX,
		rs_EX,
		rt_EX,
		writereg_MEM,
		writereg_WB,
		regwrite_MEM,		
		regwrite_WB,					 
		selSrca,
		selSrcB
	);
	
  HZD: hazard_detector
  	port map(
  		reset,
		pcsrc,
		jump,
		instr_ID(31 downto 26),
		instr_ID(25 downto 21), 
		instr_ID(20 downto 16),
		writereg_EX,
		memtoreg_EX,
		enable_PCplus4,
		enable_IF_ID,
		enable_ID_EX,
		reset_IF_ID,
		reset_ID_EX,
		reset_EX_MEM,
		reset_MEM_WB
	); 
  
  -- ALU logic	 
  -- srcbmux
  srcbmux: mux2 generic map(32) 
  port map(writedata_MUX, signimm_EX, alusrc_EX, srcb_ALU);
  
  with selSrca select
  srca_ALU <= srca_EX when "00",
	 	      result  when "01",
	          aluout  when others;		
				   
  with selSrcb select
  writedata_MUX <= writedata_EX when "00",
	 	          result  when "01",
	              aluout  when others;				   
 
  mainalu: alu 
  port map(srca_ALU, srcb_ALU, alucontrol_EX, aluout_EX, zero_EX);	
  
end;
