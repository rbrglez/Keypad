---------------------------------------------------------------------------------------------------
--! @brief  
--! @details 
--!
--! @author 
--!
--! @file KeypadArty.vhd
--!
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library surf;
use surf.StdRtlPkg.all;

--use work.MarkDebugPkg.all;
library UNISIM;
use UNISIM.VComponents.all;

entity KeypadArty is
   generic (
      TPD_G : time := 1 ns
   );
   port (
      CLK100MHZ : in sl;
      ck_rst    : in sl;

      -- white LEDs
      led : out slv(3 downto 0)
   );
end KeypadArty;
---------------------------------------------------------------------------------------------------    
architecture rtl of KeypadArty is

   signal clk : sl;
   signal rst : sl;


---------------------------------------------------------------------------------------------------
begin

   clk <= CLK100MHZ;
   rst <= not(ck_rst);

   led <= "0101";

end rtl;
---------------------------------------------------------------------------------------------------