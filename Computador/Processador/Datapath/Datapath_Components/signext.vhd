library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity signext is -- sign extender
  port(extSign: in STD_LOGIC;
       a:      in  STD_LOGIC_VECTOR(15 downto 0);   
       y:      out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of signext is
begin
  y <= X"ffff" & a when (extSign and a(15)) else X"0000" & a; 
end;
