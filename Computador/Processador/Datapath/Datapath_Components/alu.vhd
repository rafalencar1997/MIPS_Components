library IEEE; use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD_UNSIGNED.all;

entity alu is 
  port(a, b:       in  STD_LOGIC_VECTOR(31 downto 0);
       alucontrol: in  STD_LOGIC_VECTOR(2 downto 0);
       result:     buffer STD_LOGIC_VECTOR(31 downto 0);
       zero:       out STD_LOGIC);
end;

architecture behave of alu is
  signal condinvb, sum: STD_LOGIC_VECTOR(31 downto 0);
begin
  condinvb <= not b when alucontrol(2) else b;
  sum <= a + condinvb + alucontrol(2);

  process(all) begin
    case alucontrol(1 downto 0) is
      when "00"   => result <= a and b; 
      when "01"   => result <= a or b; 
      when "10"   => result <= sum; 
      when "11"   => result <= (0 => sum(31), others => '0'); 
      when others => result <= (others => 'X'); 
    end case;
  end process;

  zero <= '1' when result = X"00000000" else '0';
end;