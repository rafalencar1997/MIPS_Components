library IEEE; use IEEE.STD_LOGIC_1164.all;

entity maindec is -- main control decoder
  port(op:                 in  STD_LOGIC_VECTOR(5 downto 0);
       memtoreg, memwrite: out STD_LOGIC;
       branch, Nbranch:    out STD_LOGIC;
	   extSign, alusrc:    out STD_LOGIC;
       regdst, regwrite:   out STD_LOGIC;
       jump:               out STD_LOGIC;
       aluop:              out STD_LOGIC_VECTOR(1 downto 0));
end;

architecture behave of maindec is
  signal controls: STD_LOGIC_VECTOR(10 downto 0);
begin
  process(all) begin
    case op is
      when "000000" => controls <= "11000000010"; -- RTYPE  
      when "000010" => controls <= "00000000100"; -- J	
      when "000100" => controls <= "00001000001"; -- BEQ
      when "000101" => controls <= "00000100001"; -- BNE
      when "001000" => controls <= "10110000000"; -- ADDI   
      when "001101" => controls <= "10100000011"; -- ORI	
      when "100011" => controls <= "10110001000"; -- LW
      when "101011" => controls <= "00110010000"; -- SW
	  when others   => controls <= "-----------"; -- illegal op
    end case;
  end process;

  (regwrite, regdst, alusrc, extSign, branch, Nbranch, memwrite,
   memtoreg, jump, aluop(1 downto 0)) <= controls;
end;
